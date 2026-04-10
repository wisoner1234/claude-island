//
//  OwlIcon.swift
//  ClaudeIsland
//
//  Pixel art owl icon for the notch
//

import SwiftUI
import Combine

struct OwlIcon: View {
    let size: CGFloat
    let color: Color
    var animate: Bool = false

    @State private var phase: Int = 0
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, canvasSize in
            let s = size / 40.0

            // Ear tufts
            let earTufts: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (4, 0, 4, 4),
                (28, 0, 4, 4),
            ]

            // Body
            let body: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (4, 4, 28, 4),
                (0, 8, 36, 4),
                (0, 12, 36, 4),
                (0, 16, 36, 4),
                (0, 20, 36, 4),
                (4, 24, 28, 4),
                (8, 28, 20, 4),
            ]

            // Eyes (big round owl eyes - blink when animated)
            let isBlinking = animate && phase % 6 == 5
            let eyes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = if isBlinking {
                [
                    (8, 14, 8, 2),
                    (20, 14, 8, 2),
                ]
            } else {
                [
                    (8, 12, 8, 6),
                    (20, 12, 8, 6),
                ]
            }

            // Pupils
            let pupils: [(CGFloat, CGFloat, CGFloat, CGFloat)] = if isBlinking {
                []
            } else {
                [
                    (10, 14, 4, 4),
                    (22, 14, 4, 4),
                ]
            }

            // Beak
            let beak: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (16, 20, 4, 4),
            ]

            // Wings
            let wings: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (0, 16, 4, 8),
                (32, 16, 4, 8),
            ]

            // Feet
            let feet: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (8, 32, 4, 4),
                (12, 32, 4, 4),
                (20, 32, 4, 4),
                (24, 32, 4, 4),
            ]

            func drawRects(_ rects: [(CGFloat, CGFloat, CGFloat, CGFloat)], fillColor: Color) {
                for (x, y, w, h) in rects {
                    let rect = CGRect(x: x * s, y: y * s, width: w * s, height: h * s)
                    context.fill(Path(rect), with: .color(fillColor))
                }
            }

            drawRects(earTufts, fillColor: color)
            drawRects(body, fillColor: color)
            drawRects(wings, fillColor: Color(red: 0.7, green: 0.37, blue: 0.27))
            drawRects(eyes, fillColor: .white)
            drawRects(pupils, fillColor: .black)
            drawRects(beak, fillColor: Color(red: 1.0, green: 0.7, blue: 0.2))
            drawRects(feet, fillColor: Color(red: 1.0, green: 0.7, blue: 0.2))
        }
        .frame(width: size, height: size)
        .onReceive(timer) { _ in
            if animate { phase += 1 }
        }
    }
}
