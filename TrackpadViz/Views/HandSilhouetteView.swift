import SwiftUI

struct HandSilhouetteView: View {
    @Environment(TouchState.self) var state

    var body: some View {
        VStack(spacing: 4) {
            Text("HANDS")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))

            HStack(spacing: 24) {
                SingleHandView(isLeft: true, touches: leftTouches)
                SingleHandView(isLeft: false, touches: rightTouches)
            }
            .padding(.vertical, 8)
        }
    }

    private var leftTouches: [TouchData] {
        state.activeTouches.filter { $0.isTouching && $0.handId == 0 }
    }

    private var rightTouches: [TouchData] {
        state.activeTouches.filter { $0.isTouching && $0.handId == 1 }
    }
}

struct SingleHandView: View {
    let isLeft: Bool
    let touches: [TouchData]

    // Finger positions relative to hand center, normalized
    // Order: thumb, index, middle, ring, pinky
    private var fingerPositions: [(x: CGFloat, y: CGFloat, length: CGFloat)] {
        // Palms facing down, thumbs toward center
        if isLeft {
            return [
                (x: 0.52, y: 0.10, length: 0.55),    // thumb (inner)
                (x: 0.28, y: -0.50, length: 0.70),   // index
                (x: 0.05, y: -0.58, length: 0.75),   // middle
                (x: -0.18, y: -0.50, length: 0.68),  // ring
                (x: -0.38, y: -0.38, length: 0.55),  // pinky (outer)
            ]
        } else {
            return [
                (x: -0.52, y: 0.10, length: 0.55),   // thumb (inner)
                (x: -0.28, y: -0.50, length: 0.70),  // index
                (x: -0.05, y: -0.58, length: 0.75),  // middle
                (x: 0.18, y: -0.50, length: 0.68),   // ring
                (x: 0.38, y: -0.38, length: 0.55),   // pinky (outer)
            ]
        }
    }

    private let fingerNames = ["thumb", "index", "middle", "ring", "pinky"]

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height * 0.6)
            let scale = min(size.width, size.height) * 0.45

            // Palm
            let palmRect = CGRect(
                x: center.x - scale * 0.38,
                y: center.y - scale * 0.30,
                width: scale * 0.76,
                height: scale * 0.70
            )
            let palm = Path(roundedRect: palmRect, cornerRadius: scale * 0.15)
            let anyActive = !touches.isEmpty
            context.fill(palm, with: .color(anyActive ? Color.white.opacity(0.12) : Color.white.opacity(0.05)))
            context.stroke(palm, with: .color(Color.white.opacity(0.15)), lineWidth: 1)

            // Fingers
            for (i, pos) in fingerPositions.enumerated() {
                let fingerTouch = touches.first { $0.fingerId == i }
                let isActive = fingerTouch != nil

                let fx = center.x + pos.x * scale
                let fy = center.y + pos.y * scale

                // Finger capsule
                let capsuleWidth: CGFloat = scale * 0.18
                let capsuleHeight: CGFloat = scale * pos.length

                let isThumb = (i == 0)
                let thumbAngle: CGFloat = isLeft ? -0.5 : 0.5

                var ctx = context
                ctx.translateBy(x: fx, y: fy)
                if isThumb {
                    ctx.rotate(by: .radians(thumbAngle))
                }

                let capsuleRect = CGRect(
                    x: -capsuleWidth / 2,
                    y: -capsuleHeight,
                    width: capsuleWidth,
                    height: capsuleHeight
                )
                let capsule = Path(roundedRect: capsuleRect, cornerRadius: capsuleWidth / 2)

                if isActive {
                    let pressure = fingerTouch!.total
                    let color = Color.forPressure(pressure)
                    // Glow
                    let glowRect = capsuleRect.insetBy(dx: -3, dy: -3)
                    let glow = Path(roundedRect: glowRect, cornerRadius: capsuleWidth / 2 + 3)
                    ctx.fill(glow, with: .color(color.opacity(0.3)))
                    ctx.fill(capsule, with: .color(color.opacity(0.8)))
                } else {
                    ctx.fill(capsule, with: .color(Color.white.opacity(0.06)))
                    ctx.stroke(capsule, with: .color(Color.white.opacity(0.1)), lineWidth: 0.5)
                }

                // Finger tip circle
                let tipY = -capsuleHeight + capsuleWidth / 2
                let tipRect = CGRect(
                    x: -capsuleWidth * 0.3,
                    y: tipY - capsuleWidth * 0.3,
                    width: capsuleWidth * 0.6,
                    height: capsuleWidth * 0.6
                )
                if isActive {
                    ctx.fill(Path(ellipseIn: tipRect), with: .color(.white.opacity(0.5)))
                }
            }

            // Hand label
            let label = Text(isLeft ? "LEFT" : "RIGHT")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
            context.draw(label, at: CGPoint(x: size.width / 2, y: size.height - 4))
        }
        .frame(width: 100, height: 160)
    }
}
