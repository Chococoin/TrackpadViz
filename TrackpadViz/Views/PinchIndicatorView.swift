import SwiftUI

struct PinchIndicatorView: View {
    var magnification: Double

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: 80, height: 80)

                Circle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(
                        width: max(10, min(80, 40 * magnification)),
                        height: max(10, min(80, 40 * magnification))
                    )
                    .animation(.easeOut(duration: 0.1), value: magnification)
            }

            Text("\(String(format: "%.2f", magnification))x")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}
