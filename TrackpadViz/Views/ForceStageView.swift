import SwiftUI

struct ForceStageView: View {
    var stage: Int

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colorForStage(i))
                        .frame(width: 30, height: 12)
                }
            }
            Text("Force Stage \(stage)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    private func colorForStage(_ index: Int) -> Color {
        if index < stage {
            switch index {
            case 0: return .green
            case 1: return .yellow
            default: return .red
            }
        } else if index == stage && stage > 0 {
            switch index {
            case 0: return .green
            case 1: return .yellow
            default: return .red
            }
        }
        return Color.white.opacity(0.15)
    }
}
