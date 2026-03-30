import SwiftUI

struct MetricsPanelView: View {
    @Environment(TouchState.self) var state

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Hand silhouettes
                HandSilhouetteView()

                Divider().background(Color.white.opacity(0.2))

                // Finger count
                VStack(spacing: 2) {
                    Text("\(state.fingerCount)")
                        .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.white)
                    Text("FINGERS")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }

                Divider().background(Color.white.opacity(0.2))

                // Rotation
                VStack(spacing: 4) {
                    Text("ROTATION")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                    RotationDialView(rotation: state.rotation)
                }

                Divider().background(Color.white.opacity(0.2))

                // Pinch
                VStack(spacing: 4) {
                    Text("PINCH")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                    PinchIndicatorView(magnification: state.magnification)
                }

                Divider().background(Color.white.opacity(0.2))

                // Scroll
                VStack(spacing: 4) {
                    Text("SCROLL DELTA")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 16) {
                        VStack {
                            Text("X")
                                .foregroundColor(.white.opacity(0.4))
                            Text(String(format: "%.4f", state.scrollDelta.x))
                                .foregroundColor(.cyan)
                        }
                        VStack {
                            Text("Y")
                                .foregroundColor(.white.opacity(0.4))
                            Text(String(format: "%.4f", state.scrollDelta.y))
                                .foregroundColor(.cyan)
                        }
                    }
                    .font(.system(size: 12, design: .monospaced))
                }

                Divider().background(Color.white.opacity(0.2))

                // Force Touch
                ForceStageView(stage: state.forceStage)

                Divider().background(Color.white.opacity(0.2))

                // Per-finger details
                VStack(alignment: .leading, spacing: 4) {
                    Text("FINGER DETAILS")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))

                    if state.activeTouches.isEmpty {
                        Text("No active touches")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.vertical, 4)
                    } else {
                        ForEach(state.activeTouches, id: \.id) { touch in
                            FingerDetailView(touch: touch)
                        }
                    }
                }

                Divider().background(Color.white.opacity(0.2))

                // Reset buttons
                HStack(spacing: 12) {
                    Button("Reset Gestures") {
                        state.resetGestures()
                    }
                    .buttonStyle(.bordered)

                    Button("Reset Heatmap") {
                        state.resetHeatmap()
                    }
                    .buttonStyle(.bordered)
                }
                .font(.system(size: 11))
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 12)
        }
    }
}
