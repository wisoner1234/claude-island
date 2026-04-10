//
//  IconPickerRow.swift
//  ClaudeIsland
//
//  Notch icon selection picker for settings menu
//

import SwiftUI

struct IconPickerRow: View {
    @State private var isHovered = false
    @State private var isExpanded = false
    @State private var selectedIcon: NotchIconTheme = AppSettings.notchIcon

    var body: some View {
        VStack(spacing: 0) {
            // Main row - shows current selection
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "face.dashed")
                        .font(.system(size: 12))
                        .foregroundColor(textColor)
                        .frame(width: 16)

                    Text("Notch Icon")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(textColor)

                    Spacer()

                    // Small preview of current icon
                    selectedIcon.makeIcon(size: 16, animate: false)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isHovered ? Color.white.opacity(0.08) : Color.clear)
                )
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }

            // Expanded icon list
            if isExpanded {
                VStack(spacing: 2) {
                    ForEach(NotchIconTheme.allCases, id: \.self) { theme in
                        IconOptionRow(
                            theme: theme,
                            isSelected: selectedIcon == theme
                        ) {
                            selectedIcon = theme
                            AppSettings.notchIcon = theme
                        }
                    }
                }
                .padding(.leading, 28)
                .padding(.top, 4)
            }
        }
        .onAppear {
            selectedIcon = AppSettings.notchIcon
        }
    }

    private var textColor: Color {
        .white.opacity(isHovered ? 1.0 : 0.7)
    }
}

private struct IconOptionRow: View {
    let theme: NotchIconTheme
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? TerminalColors.green : Color.white.opacity(0.2))
                    .frame(width: 6, height: 6)

                theme.makeIcon(size: 18, animate: false)

                Text(theme.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(isHovered ? 1.0 : 0.7))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(TerminalColors.green)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.white.opacity(0.06) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
