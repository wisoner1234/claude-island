//
//  TerminalMessenger.swift
//  ClaudeIsland
//
//  Sends messages to non-tmux terminals via CGEvent keystroke injection
//

import ApplicationServices
import AppKit
import Foundation
import os.log

/// Sends text messages to non-tmux terminal applications.
/// Uses CGEvent Unicode key injection to type text directly — no clipboard tampering.
/// Requires Accessibility permission for the app.
actor TerminalMessenger {
    static let shared = TerminalMessenger()

    nonisolated static let logger = Logger(subsystem: "com.claudeisland", category: "TerminalMessenger")

    private init() {}

    /// Send a text message to the terminal running a Claude session
    func sendMessage(_ text: String, toSessionPid pid: Int) async -> Bool {
        // 1. Check Accessibility permission (prompt user if not granted)
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        let axTrusted = AXIsProcessTrustedWithOptions(options)
        guard axTrusted else {
            Self.logger.error("Accessibility permission not granted")
            return false
        }

        // 2. Walk process tree to find terminal app
        let tree = ProcessTreeBuilder.shared.buildTree()
        guard let terminalPid = ProcessTreeBuilder.shared.findTerminalPid(forProcess: pid, tree: tree),
              let terminalInfo = tree[terminalPid]
        else {
            Self.logger.error("Could not find terminal app for PID \(pid)")
            return false
        }

        // 3. Resolve to a running NSRunningApplication for reliable activation
        guard let runningApp = findRunningApp(forPid: terminalPid, command: terminalInfo.command) else {
            Self.logger.error("Could not find running app for terminal PID \(terminalPid)")
            return false
        }

        // 4. Activate the terminal app
        guard runningApp.activate() else {
            Self.logger.error("Failed to activate app: \(runningApp.localizedName ?? "unknown")")
            return false
        }

        // 5. Wait for app to come to foreground, then type text + Enter
        try? await Task.sleep(for: .milliseconds(300))
        typeTextViaCGEvent(text)
        try? await Task.sleep(for: .milliseconds(50))
        postKeyPress(keyCode: 0x24) // Enter

        return true
    }

    // MARK: - App Resolution

    /// Find the NSRunningApplication for a terminal process.
    /// Prefers matching by PID (exact), falls back to bundle ID or display name.
    private nonisolated func findRunningApp(forPid pid: Int, command: String) -> NSRunningApplication? {
        let workspace = NSWorkspace.shared

        // Exact match by PID
        if let app = workspace.runningApplications.first(where: { Int($0.processIdentifier) == pid }) {
            return app
        }

        // Fall back: match by bundle identifier derived from process command
        let basename = URL(fileURLWithPath: command).lastPathComponent
        let bundleIdMap: [String: String] = [
            "Terminal": "com.apple.Terminal",
            "iTerm2": "com.googlecode.iterm2",
            "iTerm": "com.googlecode.iterm2",
            "Ghostty": "com.mitchellh.ghostty",
            "Alacritty": "io.alacritty",
            "Warp": "dev.warp.Warp-Stable",
            "WezTerm": "com.github.wez.wezterm",
            "wezterm-gui": "com.github.wez.wezterm",
            "Code": "com.microsoft.VSCode",
            "Code - Insiders": "com.microsoft.VSCodeInsiders",
            "Cursor": "com.todesktop.230313mzl4w4u92",
            "Windsurf": "com.exafunction.windsurf",
            "zed": "dev.zed.Zed",
            "kitty": "net.kovidgoyal.kitty",
            "Hyper": "co.zeit.hyper",
        ]

        // Try bundle ID match
        if let bundleId = bundleIdMap[basename],
           let app = workspace.runningApplications.first(where: { $0.bundleIdentifier == bundleId && $0.isActive }) {
            return app
        }

        // Try display name match
        let displayName = resolveDisplayName(from: command)
        return workspace.runningApplications.first { $0.localizedName == displayName }
    }

    /// Map process command path to application display name for UI activation
    private nonisolated func resolveDisplayName(from command: String) -> String {
        let lower = command.lowercased()

        // Match by full path first (handles VS Code helper processes)
        if lower.contains("visual studio code") { return "Visual Studio Code" }
        if lower.contains("cursor") { return "Cursor" }
        if lower.contains("windsurf") { return "Windsurf" }

        // Fall back to basename mapping
        let basename = URL(fileURLWithPath: command).lastPathComponent
        let nameMap: [String: String] = [
            "Terminal": "Terminal",
            "iTerm2": "iTerm",
            "iTerm": "iTerm",
            "Ghostty": "Ghostty",
            "Warp": "Warp",
            "Code": "Visual Studio Code",
            "Code - Insiders": "Visual Studio Code",
            "Cursor": "Cursor",
            "Alacritty": "Alacritty",
            "kitty": "kitty",
            "WezTerm": "WezTerm",
            "wezterm-gui": "WezTerm",
            "Windsurf": "Windsurf",
            "zed": "Zed",
            "Hyper": "Hyper",
        ]

        return nameMap[basename] ?? basename
    }

    // MARK: - CGEvent Keyboard Simulation

    /// Type text character-by-character using CGEvent Unicode events.
    /// No clipboard involved — types directly into the frontmost app.
    private nonisolated func typeTextViaCGEvent(_ text: String) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        for char in text {
            let utf16 = Array(String(char).utf16)
            // Send key-down with Unicode character
            if let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
                utf16.withUnsafeBufferPointer { buf in
                    event.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: buf.baseAddress!)
                }
                event.post(tap: .cghidEventTap)
            }
            // Send key-up
            if let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
                utf16.withUnsafeBufferPointer { buf in
                    event.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: buf.baseAddress!)
                }
                event.post(tap: .cghidEventTap)
            }
        }
    }

    /// Post a single key press
    private nonisolated func postKeyPress(keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        if let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) {
            event.post(tap: .cghidEventTap)
        }
        if let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            event.post(tap: .cghidEventTap)
        }
    }
}
