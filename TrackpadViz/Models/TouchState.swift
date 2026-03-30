import Foundation

@Observable
@MainActor
final class TouchState {
    var activeTouches: [TouchData] = []
    var rotation: Double = 0.0
    var magnification: Double = 1.0
    var scrollDelta: CGPoint = .zero
    var forceStage: Int = 0
    var fingerCount: Int = 0
    var heatmap: HeatmapData = HeatmapData()
    var eventLog: EventLog = EventLog()
    var previousTouches: [Int32: TouchData] = [:]

    private var gestureComputer = GestureComputer()
    private var frameCount = 0

    func start() {
        RawMultitouchBridge.shared().start { [weak self] rawTouches in
            guard let self, let rawTouches else { return }
            let touches = rawTouches.map { TouchData(from: $0 as NSDictionary) }
            self.processFrame(touches)
        }
    }

    func stop() {
        RawMultitouchBridge.shared().stop()
    }

    private func processFrame(_ touches: [TouchData]) {
        activeTouches = touches
        fingerCount = touches.filter(\.isTouching).count

        let gestures = gestureComputer.update(
            touches: touches,
            previous: previousTouches
        )
        rotation += gestures.deltaRotation
        magnification *= (1.0 + gestures.deltaMagnification)
        scrollDelta = gestures.scrollDelta
        forceStage = gestures.forceStage

        for touch in touches where touch.isTouching {
            heatmap.accumulate(x: touch.posX, y: touch.posY, weight: touch.total)
        }

        frameCount += 1
        if frameCount % 5 == 0 && !touches.isEmpty {
            let fingerInfo = touches.filter(\.isTouching).map { t in
                "id:\(t.id) h:\(t.handId) f:\(t.fingerId)(\(t.fingerName)) pos:(\(String(format: "%.2f", t.posX)),\(String(format: "%.2f", t.posY)))"
            }.joined(separator: " | ")
            if !fingerInfo.isEmpty {
                eventLog.append("[\(fingerCount)F] \(fingerInfo)")
            }
        }

        previousTouches = Dictionary(
            uniqueKeysWithValues: touches.map { ($0.id, $0) }
        )
    }

    func resetHeatmap() {
        heatmap.reset()
    }

    func resetGestures() {
        rotation = 0
        magnification = 1.0
        scrollDelta = .zero
        forceStage = 0
    }
}
