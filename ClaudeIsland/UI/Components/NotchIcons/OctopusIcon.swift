//
//  OctopusIcon.swift
//  ClaudeIsland
//
//  Pixel art octopus icon for the notch
//

import SwiftUI
import Combine

struct OctopusIcon: View {
    let size: CGFloat
    let color: Color
    var animate: Bool = false

    @State private var phase: Int = 0
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, canvasSize in
            let s = size / 40.0

            // Head (round dome)
            let head: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (12, 0, 12, 4),
                (8, 4, 20, 4),
                (4, 8, 28, 4),
                (4, 12, 28, 4),
                (4, 16, 28, 4),
            ]

            // Eyes
            let eyes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (10, 10, 4, 4),
                (22, 10, 4, 4),
            ]

            // Tentacles (animated wave pattern)
            let waveShift = animate ? phase % 2 : 0
            let tentacleOffsets: [[CGFloat]] = [
                [0, 0, 0, 0, 0, 0],
                [2, -2, 2, -2, 2, -2],
            ]
            let offsets = tentacleOffsets[waveShift]

            var tentacles: [(CGFloat, CGFloat, CGFloat, CGFloat)] = []
            let tentacleXPositions: [CGFloat] = [4, 10, 16, 22, 28, 34]
            for (i, x) in tentacleXPositions.enumerated() {
                let dx = offsets[i]
                tentacles.append((x + dx, 20, 4, 4))
                tentacles.append((x + dx * -1, 24, 4, 4))
                tentacles.append((x + dx, 28, 4, 4))
                tentacles.append((x + dx * -1, 32, 4, 4))
            }

            // Suction cups (lighter color dots on tentacles)
            let cupColor = Color(red: 0.95, green: 0.55, blue: 0.45)
            let cups: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (6, 24, 2, 2),
                (12, 28, 2, 2),
                (18, 24, 2, 2),
                (24, 28, 2, 2),
                (30, 24, 2, 2),
                (36, 28, 2, 2),
            ]

            func drawRects(_ rects: [(CGFloat, CGFloat, CGFloat, CGFloat)], fillColor: Color) {
                for (x, y, w, h) in rects {
                    let rect = CGRect(x: x * s, y: y * s, width: w * s, height: h * s)
                    context.fill(Path(rect), with: .color(fillColor))
                }
            }

            drawRects(head, fillColor: color)
            drawRects(tentacles, fillColor: color)
            drawRects(cups, fillColor: cupColor)
            drawRects(eyes, fillColor: .black)
        }
        .frame(width: size, height: size)
        .frame(width: size * (66.0 / 52.0), height: size, alignment: .center)
        .onReceive(timer) { _ in
            if animate { phase += 1 }
        }
    }
}
