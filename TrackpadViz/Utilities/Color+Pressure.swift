import SwiftUI

extension Color {
    static func forPressure(_ value: Float) -> Color {
        let v = Double(min(max(value, 0), 1))
        if v < 0.5 {
            return Color(red: v * 2, green: 1.0, blue: 0)
        } else {
            return Color(red: 1.0, green: 1.0 - (v - 0.5) * 2, blue: 0)
        }
    }
}
