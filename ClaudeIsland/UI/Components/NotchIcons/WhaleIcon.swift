//
//  WhaleIcon.swift
//  ClaudeIsland
//
//  Pixel art whale icon for the notch
//

import SwiftUI
import Combine

struct WhaleIcon: View {
    let size: CGFloat
    let color: Color
    var animate: Bool = false

    @State private var phase: Int = 0
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, canvasSize in
            let s = size / 40.0

            // Water spout (animated)
            let spoutVisible = !animate || phase % 4 != 3
            let spout: [(CGFloat, CGFloat, CGFloat, CGFloat)] = spoutVisible ? [
                (16, 0, 4, 4),
                (14, 4, 4, 4),
                (20, 4, 4, 4),
                (16, 8, 4, 4),
            ] : []

            // Body
            let body: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (4, 12, 28, 4),
                (0, 16, 36, 4),
                (0, 20, 36, 4),
                (0, 24, 36, 4),
                (4, 28, 28, 4),
            ]

            // Belly (lighter)
            let belly: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (4, 24, 28, 4),
            ]

            // Eye
            let eye: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (28, 16, 4, 4),
            ]

            // Tail
            let tail: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (0, 12, 4, 4),
                (0, 16, 4, 4),
                (0, 28, 4, 4),
                (0, 24, 4, 4),
                (4, 8, 4, 4),
                (4, 28, 4, 4),
            ]

            // Fin
            let fin: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (16, 28, 4, 4),
                (16, 32, 4, 4),
            ]

            func drawRects(_ rects: [(CGFloat, CGFloat, CGFloat, CGFloat)], fillColor: Color) {
                for (x, y, w, h) in rects {
                    let rect = CGRect(x: x * s, y: y * s, width: w * s, height: h * s)
                    context.fill(Path(rect), with: .color(fillColor))
                }
            }

            drawRects(spout, fillColor: Color(red: 0.4, green: 0.7, blue: 1.0))
            drawRects(tail, fillColor: color)
            drawRects(body, fillColor: color)
            drawRects(belly, fillColor: Color(red: 0.9, green: 0.6, blue: 0.5))
            drawRects(fin, fillColor: Color(red: 0.7, green: 0.37, blue: 0.27))
            drawRects(eye, fillColor: .black)
        }
        .frame(width: size, height: size)
        .frame(width: size * (66.0 / 52.0), height: size, alignment: .center)
        .onReceive(timer) { _ in
            if animate { phase += 1 }
        }
    }
}
