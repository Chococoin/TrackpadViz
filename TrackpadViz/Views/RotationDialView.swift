import SwiftUI

struct RotationDialView: View {
    var rotation: Double

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 2)

            // Tick marks
            ForEach(0..<12, id: \.self) { i in
                let angle = Angle.degrees(Double(i) * 30)
                Rectangle()
                    .fill(Color.white.opacity(i % 3 == 0 ? 0.5 : 0.2))
                    .frame(width: 1, height: i % 3 == 0 ? 10 : 5)
                    .offset(y: -40)
                    .rotationEffect(angle)
            }

            // Needle
            Rectangle()
                .fill(Color.orange)
                .frame(width: 2, height: 35)
                .offset(y: -17.5)
                .rotationEffect(.degrees(rotation))

            // Center dot
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)

            // Degree label
            Text("\(String(format: "%.1f", rotation))°")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .offset(y: 25)
        }
        .frame(width: 100, height: 100)
    }
}
