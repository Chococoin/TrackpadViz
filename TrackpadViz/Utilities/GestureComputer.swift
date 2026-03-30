import Foundation

struct GestureResult {
    var deltaRotation: Double = 0
    var deltaMagnification: Double = 0
    var scrollDelta: CGPoint = .zero
    var forceStage: Int = 0
}

struct GestureComputer {
    mutating func update(
        touches: [TouchData],
        previous: [Int32: TouchData]
    ) -> GestureResult {
        var result = GestureResult()

        let activeTouches = touches.filter(\.isTouching)

        if let maxTotal = activeTouches.map(\.total).max() {
            if maxTotal >= 0.8 {
                result.forceStage = 2
            } else if maxTotal >= 0.5 {
                result.forceStage = 1
            }
        }

        if activeTouches.count >= 2 {
            let t0 = activeTouches[0]
            let t1 = activeTouches[1]

            if let p0 = previous[t0.id], let p1 = previous[t1.id] {
                let dx = Double(t1.posX - t0.posX)
                let dy = Double(t1.posY - t0.posY)
                let currentAngle = atan2(dy, dx)
                let currentDist = sqrt(dx * dx + dy * dy)

                let pdx = Double(p1.posX - p0.posX)
                let pdy = Double(p1.posY - p0.posY)
                let prevAngle = atan2(pdy, pdx)
                let prevDist = sqrt(pdx * pdx + pdy * pdy)

                var angleDelta = currentAngle - prevAngle
                if angleDelta > .pi { angleDelta -= 2 * .pi }
                if angleDelta < -.pi { angleDelta += 2 * .pi }
                result.deltaRotation = angleDelta * 180.0 / .pi

                if prevDist > 0.001 {
                    result.deltaMagnification = (currentDist - prevDist) / prevDist
                }
            }
        }

        if !activeTouches.isEmpty {
            var totalDx: Double = 0
            var totalDy: Double = 0
            var count = 0
            for touch in activeTouches {
                if let prev = previous[touch.id] {
                    totalDx += Double(touch.posX - prev.posX)
                    totalDy += Double(touch.posY - prev.posY)
                    count += 1
                }
            }
            if count > 0 {
                result.scrollDelta = CGPoint(
                    x: totalDx / Double(count),
                    y: totalDy / Double(count)
                )
            }
        }

        return result
    }
}
