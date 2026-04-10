//
//  CatIcon.swift
//  ClaudeIsland
//
//  Pixel art cat icon for the notch
//

import SwiftUI
import Combine

struct CatIcon: View {
    let size: CGFloat
    let color: Color
    var animate: Bool = false

    @State private var phase: Int = 0
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, canvasSize in
            let s = size / 40.0

            // Pixel art cat (40x40 grid):
            // Two triangular ears, round head, two eyes, nose, whiskers, tail

            // Left ear (triangle approximated with rects)
            let leftEar: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (4, 0, 4, 4),
                (0, 4, 12, 4),
            ]
            // Right ear
            let rightEar: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (24, 0, 4, 4),
                (20, 4, 12, 4),
            ]
            // Head
            let head: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (4, 8, 28, 4),
                (0, 12, 36, 4),
                (0, 16, 36, 4),
                (0, 20, 36, 4),
                (4, 24, 28, 4),
            ]
            // Eyes
            let eyes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (8, 16, 4, 4),
                (24, 16, 4, 4),
            ]
            // Nose
            let nose: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (16, 20, 4, 4),
            ]

            // Tail (animated)
            let tailOffset: CGFloat = animate ? CGFloat(phase % 3) * 4 : 0
            let tail: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (36 + tailOffset, 12, 4, 4),
                (36, 16, 4, 4),
                (36, 20, 4, 4),
                (36, 24, 4, 4),
            ]

            func drawRects(_ rects: [(CGFloat, CGFloat, CGFloat, CGFloat)], fillColor: Color) {
                for (x, y, w, h) in rects {
                    let rect = CGRect(x: x * s, y: y * s, width: w * s, height: h * s)
                    context.fill(Path(rect), with: .color(fillColor))
                }
            }

            // Draw ears
            drawRects(leftEar, fillColor: color)
            drawRects(rightEar, fillColor: color)
            // Draw head
            drawRects(head, fillColor: color)
            // Draw tail
            drawRects(tail, fillColor: color)
            // Draw eyes
            drawRects(eyes, fillColor: .black)
            // Draw nose
            drawRects(nose, fillColor: Color(red: 1.0, green: 0.6, blue: 0.5))
        }
        .frame(width: size, height: size)
        .frame(width: size * (66.0 / 52.0), height: size, alignment: .center)
        .onReceive(timer) { _ in
            if animate { phase = (phase + 1) % 3 }
        }
    }
}
