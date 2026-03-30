import SwiftUI

struct TrackpadCanvasView: View {
    @Environment(TouchState.self) var state

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let bg = Path(roundedRect: rect, cornerRadius: 16)
            context.fill(bg, with: .color(.black.opacity(0.85)))

            let gridColor = Color.white.opacity(0.08)
            for i in 1..<10 {
                let x = size.width * CGFloat(i) / 10.0
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
            for i in 1..<8 {
                let y = size.height * CGFloat(i) / 8.0
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }

            for touch in state.activeTouches {
                guard touch.isTouching else { continue }

                let cx = CGFloat(touch.posX) * size.width
                let cy = CGFloat(1.0 - touch.posY) * size.height

                let scale: CGFloat = size.width * 0.008
                let majorR = CGFloat(touch.majorAxis) * scale
                let minorR = CGFloat(touch.minorAxis) * scale
                let clampedMajor = max(majorR, 4)
                let clampedMinor = max(minorR, 3)

                let color = Color.forPressure(touch.total)

                var ctx = context
                ctx.translateBy(x: cx, y: cy)
                ctx.rotate(by: .radians(Double(touch.angle)))

                let ellipseRect = CGRect(
                    x: -clampedMajor,
                    y: -clampedMinor,
                    width: clampedMajor * 2,
                    height: clampedMinor * 2
                )
                let ellipse = Path(ellipseIn: ellipseRect)

                ctx.fill(ellipse, with: .color(color.opacity(0.3)))
                ctx.fill(
                    Path(ellipseIn: ellipseRect.insetBy(dx: 2, dy: 2)),
                    with: .color(color.opacity(0.8))
                )

                // Label: Hand + Finger
                let label = "\(touch.handLabel)\(touch.fingerName)"
                let text = Text(label)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                ctx.draw(text, at: CGPoint(x: 0, y: -clampedMinor - 8))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
        .aspectRatio(1.4, contentMode: .fit)
    }
}
