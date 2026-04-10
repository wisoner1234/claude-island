//
//  FoxIcon.swift
//  ClaudeIsland
//
//  Pixel art fox icon for the notch
//

import SwiftUI
import Combine

struct FoxIcon: View {
    let size: CGFloat
    let color: Color
    var animate: Bool = false

    @State private var phase: Int = 0
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, canvasSize in
            let s = size / 40.0

            // Left ear
            let leftEar: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (4, 0, 4, 4),
                (8, 0, 4, 4),
                (4, 4, 8, 4),
            ]
            // Right ear
            let rightEar: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (24, 0, 4, 4),
                (28, 0, 4, 4),
                (24, 4, 8, 4),
            ]
            // Inner ears (darker)
            let innerEars: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (8, 2, 4, 2),
                (24, 2, 4, 2),
            ]

            // Head
            let head: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (0, 8, 36, 4),
                (0, 12, 36, 4),
                (0, 16, 36, 4),
                (4, 20, 28, 4),
            ]

            // White muzzle/cheeks
            let muzzle: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (8, 16, 20, 4),
                (12, 20, 12, 4),
            ]

            // Eyes
            let eyeShift: CGFloat = animate && phase % 4 == 0 ? 0 : 0
            let eyes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (8 + eyeShift, 12, 4, 4),
                (24 + eyeShift, 12, 4, 4),
            ]

            // Nose
            let nose: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (16, 18, 4, 4),
            ]

            // Tail (bushy, animated)
            let tailWag: CGFloat = animate ? CGFloat(phase % 3) * 2 - 2 : 0
            let tail: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (32, 8, 4, 4),
                (32 + tailWag, 12, 4, 4),
                (32 + tailWag, 16, 4, 4),
                (32 + tailWag, 20, 4, 4),
                (36 + tailWag, 8, 4, 4),
                (36 + tailWag, 12, 4, 4),
            ]
            // Tail tip (white)
            let tailTip: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (36 + tailWag, 16, 4, 4),
                (36 + tailWag, 20, 4, 4),
            ]

            func drawRects(_ rects: [(CGFloat, CGFloat, CGFloat, CGFloat)], fillColor: Color) {
                for (x, y, w, h) in rects {
                    let rect = CGRect(x: x * s, y: y * s, width: w * s, height: h * s)
                    context.fill(Path(rect), with: .color(fillColor))
                }
            }

            drawRects(leftEar, fillColor: color)
            drawRects(rightEar, fillColor: color)
            drawRects(innerEars, fillColor: Color(red: 1.0, green: 0.7, blue: 0.4))
            drawRects(head, fillColor: color)
            drawRects(muzzle, fillColor: .white)
            drawRects(tail, fillColor: color)
            drawRects(tailTip, fillColor: .white)
            drawRects(eyes, fillColor: .black)
            drawRects(nose, fillColor: .black)
        }
        .frame(width: size, height: size)
        .frame(width: size * (66.0 / 52.0), height: size, alignment: .center)
        .onReceive(timer) { _ in
            if animate { phase += 1 }
        }
    }
}
