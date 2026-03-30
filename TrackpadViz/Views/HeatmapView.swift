import SwiftUI

struct HeatmapView: View {
    @Environment(TouchState.self) var state

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("HEATMAP")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Button("Reset") {
                    state.resetHeatmap()
                }
                .buttonStyle(.plain)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            Canvas { context, size in
                let data = state.heatmap.normalized
                let cellW = size.width / CGFloat(HeatmapData.cols)
                let cellH = size.height / CGFloat(HeatmapData.rows)

                for row in 0..<HeatmapData.rows {
                    for col in 0..<HeatmapData.cols {
                        let val = data[row][col]
                        guard val > 0.01 else { continue }
                        let rect = CGRect(
                            x: CGFloat(col) * cellW,
                            y: CGFloat(row) * cellH,
                            width: cellW + 0.5,
                            height: cellH + 0.5
                        )
                        let color = heatColor(val)
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
            .background(Color.black.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func heatColor(_ value: Double) -> Color {
        let v = min(max(value, 0), 1)
        if v < 0.33 {
            let t = v / 0.33
            return Color(red: 0, green: 0, blue: t)
        } else if v < 0.66 {
            let t = (v - 0.33) / 0.33
            return Color(red: t, green: 0, blue: 1.0 - t)
        } else {
            let t = (v - 0.66) / 0.34
            return Color(red: 1.0, green: t, blue: 0)
        }
    }
}
