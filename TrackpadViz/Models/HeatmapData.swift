import Foundation

struct HeatmapData {
    static let cols = 40
    static let rows = 30

    var grid: [[Double]] = Array(
        repeating: Array(repeating: 0.0, count: HeatmapData.cols),
        count: HeatmapData.rows
    )

    private var maxValue: Double = 1.0

    mutating func accumulate(x: Float, y: Float, weight: Float) {
        let col = min(Int(Double(x) * Double(HeatmapData.cols)), HeatmapData.cols - 1)
        let row = min(Int(Double(1.0 - y) * Double(HeatmapData.rows)), HeatmapData.rows - 1)
        guard col >= 0, row >= 0 else { return }
        grid[row][col] += Double(max(weight, 0.1))
        maxValue = max(maxValue, grid[row][col])
    }

    var normalized: [[Double]] {
        guard maxValue > 0 else { return grid }
        return grid.map { row in row.map { $0 / maxValue } }
    }

    mutating func reset() {
        grid = Array(
            repeating: Array(repeating: 0.0, count: HeatmapData.cols),
            count: HeatmapData.rows
        )
        maxValue = 1.0
    }
}
