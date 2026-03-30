import Foundation

struct TouchData: Identifiable, Sendable {
    var id: Int32
    var state: String
    var stateRaw: Int
    var fingerId: Int
    var fingerName: String
    var handId: Int
    var posX: Float
    var posY: Float
    var velX: Float
    var velY: Float
    var absPosX: Float
    var absPosY: Float
    var total: Float
    var pressure: Float
    var angle: Float
    var majorAxis: Float
    var minorAxis: Float
    var density: Float
    var timestamp: Double
    var frame: Int

    var handLabel: String {
        handId == 0 ? "L" : "R"
    }

    var isTouching: Bool {
        stateRaw == 4 || stateRaw == 3
    }

    init(from dict: NSDictionary) {
        id = (dict["id"] as? NSNumber)?.int32Value ?? 0
        state = dict["state"] as? String ?? "unknown"
        stateRaw = (dict["stateRaw"] as? NSNumber)?.intValue ?? 0
        fingerId = (dict["fingerId"] as? NSNumber)?.intValue ?? -1
        fingerName = dict["fingerName"] as? String ?? "?"
        handId = (dict["handId"] as? NSNumber)?.intValue ?? 0
        posX = (dict["posX"] as? NSNumber)?.floatValue ?? 0
        posY = (dict["posY"] as? NSNumber)?.floatValue ?? 0
        velX = (dict["velX"] as? NSNumber)?.floatValue ?? 0
        velY = (dict["velY"] as? NSNumber)?.floatValue ?? 0
        absPosX = (dict["absPosX"] as? NSNumber)?.floatValue ?? 0
        absPosY = (dict["absPosY"] as? NSNumber)?.floatValue ?? 0
        total = (dict["total"] as? NSNumber)?.floatValue ?? 0
        pressure = (dict["pressure"] as? NSNumber)?.floatValue ?? 0
        angle = (dict["angle"] as? NSNumber)?.floatValue ?? 0
        majorAxis = (dict["majorAxis"] as? NSNumber)?.floatValue ?? 0
        minorAxis = (dict["minorAxis"] as? NSNumber)?.floatValue ?? 0
        density = (dict["density"] as? NSNumber)?.floatValue ?? 0
        timestamp = (dict["timestamp"] as? NSNumber)?.doubleValue ?? 0
        frame = (dict["frame"] as? NSNumber)?.intValue ?? 0
    }
}
