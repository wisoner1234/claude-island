//
//  NotchIconTheme.swift
//  ClaudeIsland
//
//  Theme enum for selectable notch animal icons
//

import SwiftUI

enum NotchIconTheme: String, CaseIterable {
    case crab
    case cat
    case owl
    case octopus
    case whale
    case fox

    var displayName: String {
        switch self {
        case .crab: return "Crab"
        case .cat: return "Cat"
        case .owl: return "Owl"
        case .octopus: return "Octopus"
        case .whale: return "Whale"
        case .fox: return "Fox"
        }
    }

    @ViewBuilder
    func makeIcon(size: CGFloat, animate: Bool) -> some View {
        let color = Color(red: 0.85, green: 0.47, blue: 0.34)
        switch self {
        case .crab:
            ClaudeCrabIcon(size: size, color: color, animateLegs: animate)
        case .cat:
            CatIcon(size: size, color: color, animate: animate)
        case .owl:
            OwlIcon(size: size, color: color, animate: animate)
        case .octopus:
            OctopusIcon(size: size, color: color, animate: animate)
        case .whale:
            WhaleIcon(size: size, color: color, animate: animate)
        case .fox:
            FoxIcon(size: size, color: color, animate: animate)
        }
    }
}
