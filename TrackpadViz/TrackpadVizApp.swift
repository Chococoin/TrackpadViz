import SwiftUI

@main
struct TrackpadVizApp: App {
    @State private var touchState = TouchState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(touchState)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1100, height: 750)
    }
}
