import SwiftUI

struct EventLogView: View {
    @Environment(TouchState.self) var state

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("EVENT LOG")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(state.eventLog.entries.count) events")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(state.eventLog.entries) { entry in
                            HStack(spacing: 6) {
                                Text(formatTime(entry.timestamp))
                                    .foregroundColor(.green.opacity(0.6))
                                Text(entry.message)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .font(.system(size: 10, design: .monospaced))
                            .id(entry.id)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .onChange(of: state.eventLog.entries.count) { _, _ in
                    if let last = state.eventLog.entries.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color.black.opacity(0.9))
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: date)
    }
}
