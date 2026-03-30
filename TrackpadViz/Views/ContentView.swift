import SwiftUI

struct ContentView: View {
    @Environment(TouchState.self) var state

    var body: some View {
        VStack(spacing: 0) {
            HSplitView {
                // Left: trackpad canvas + heatmap
                VStack(spacing: 8) {
                    TrackpadCanvasView()
                        .padding(12)

                    HeatmapView()
                        .frame(minHeight: 120, maxHeight: 180)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                }
                .frame(minWidth: 450)

                // Right: metrics panel
                MetricsPanelView()
                    .frame(minWidth: 280, maxWidth: 400)
            }

            // Bottom: event log
            EventLogView()
                .frame(height: 140)
        }
        .background(Color(nsColor: NSColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)))
        .onAppear {
            state.start()
        }
        .onDisappear {
            state.stop()
        }
    }
}
