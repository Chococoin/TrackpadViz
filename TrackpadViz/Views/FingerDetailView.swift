import SwiftUI

struct FingerDetailView: View {
    let touch: TouchData

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.forPressure(touch.total))
                .frame(width: 8, height: 8)

            Text("\(touch.handLabel)-\(touch.fingerName)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(touch.handId == 0 ? .cyan : .orange)
                .frame(width: 55, alignment: .leading)

            Text(String(format: "pos:%.2f,%.2f", touch.posX, touch.posY))
            Text(String(format: "z:%.2f", touch.total))
            Text(String(format: "p:%.2f", touch.pressure))
            Text(String(format: "a:%.1f°", Double(touch.angle) * 180.0 / .pi))
            Text(String(format: "ax:%.2f/%.2f", touch.majorAxis, touch.minorAxis))
        }
        .font(.system(size: 10, design: .monospaced))
        .foregroundColor(.white.opacity(0.8))
        .padding(.vertical, 2)
    }
}
