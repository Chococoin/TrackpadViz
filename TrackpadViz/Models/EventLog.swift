import Foundation

struct EventLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
}

struct EventLog {
    private(set) var entries: [EventLogEntry] = []
    private let maxEntries = 500

    mutating func append(_ message: String) {
        let entry = EventLogEntry(timestamp: Date(), message: message)
        entries.append(entry)
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }
    }
}
