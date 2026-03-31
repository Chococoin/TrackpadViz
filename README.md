# TrackpadViz

Native macOS app that visualizes raw multitouch trackpad data in real-time.

Uses Apple's private `MultitouchSupport.framework` to access per-finger touch data that isn't available through any public API: contact ellipse, pressure, capacitance, velocity, finger/hand identification, and more.

## Features

- **Real-time touch canvas** — See each finger as a colored ellipse on a trackpad representation, sized by contact area and colored by pressure (green to red)
- **Hand & finger identification** — Detects which hand (left/right) and which finger (thumb, index, middle, ring, pinky) is touching
- **Hand silhouettes** — Visual diagram of both hands with active fingers highlighted
- **Gesture computation** — Rotation (degrees), pinch/magnification, and scroll delta computed from raw finger positions
- **Force Touch stages** — Visual indicator of force click stages (0/1/2)
- **Cumulative heatmap** — Shows the most-touched zones over time
- **Event log** — Scrollable real-time log of all touch events with finger details

## Raw Touch Data

Each finger reports the following data at ~60Hz:

| Field | Description |
|-------|-------------|
| `position` | Normalized X/Y (0.0–1.0) on trackpad surface |
| `absolutePosition` | Position in millimeters |
| `velocity` | Finger movement speed (normalized and mm/s) |
| `majorAxis` / `minorAxis` | Contact ellipse dimensions |
| `angle` | Rotation angle of contact ellipse (radians) |
| `total` | Total capacitance (correlates with contact area) |
| `pressure` | Force Touch pressure value |
| `density` | Area density of capacitance |
| `fingerId` | Which finger (0=thumb, 1=index, 2=middle, 3=ring, 4=pinky) |
| `handId` | Which hand (0=left, 1=right) |
| `state` | Touch lifecycle: notTouching, hovering, making, touching, breaking, leaving |

## Requirements

- macOS 14.0+
- Xcode 16+
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (for project generation)
- **App Sandbox must be disabled** — required to access the private framework
- **Accessibility permission** may be needed for the terminal or app

## Build

```bash
# Generate the Xcode project
xcodegen generate

# Build
xcodebuild -project TrackpadViz.xcodeproj -scheme TrackpadViz -configuration Debug build

# Run
open ~/Library/Developer/Xcode/DerivedData/TrackpadViz-*/Build/Products/Debug/TrackpadViz.app
```

Or open `TrackpadViz.xcodeproj` in Xcode and run directly.

## Architecture

```
TrackpadViz/
├── Models/
│   ├── TouchData.swift          # Per-finger data model with hand/finger ID
│   ├── TouchState.swift         # Central @Observable state for all views
│   ├── HeatmapData.swift        # Cumulative touch heatmap grid
│   └── EventLog.swift           # Ring buffer for event log
├── Services/
│   ├── RawMultitouch.h/.m       # ObjC bridge to MultitouchSupport.framework
│   └── MultitouchService.swift  # (reserved)
├── Views/
│   ├── ContentView.swift        # Main layout (HSplitView + log)
│   ├── TrackpadCanvasView.swift # Touch point visualization canvas
│   ├── HandSilhouetteView.swift # Hand diagrams with finger highlights
│   ├── MetricsPanelView.swift   # Side panel with all metrics
│   ├── RotationDialView.swift   # Rotation dial indicator
│   ├── PinchIndicatorView.swift # Pinch/zoom circle indicator
│   ├── ForceStageView.swift     # Force Touch stage display
│   ├── FingerDetailView.swift   # Per-finger detail row
│   ├── HeatmapView.swift        # Cumulative heatmap canvas
│   └── EventLogView.swift       # Scrollable event log
└── Utilities/
    ├── GestureComputer.swift    # Rotation/pinch/scroll from raw touches
    └── Color+Pressure.swift     # Pressure-to-color gradient
```

The app loads `MultitouchSupport.framework` at runtime via `dlopen` and registers a contact frame callback. Each frame delivers an array of `MTTouch` structs (one per finger) which are bridged to Swift through an ObjC layer and fed into the `@Observable` `TouchState` that drives all SwiftUI views.

## Limitations

- Uses a **private API** — Apple could break it in any macOS update without notice
- Cannot be distributed on the Mac App Store (requires sandbox disabled)
- Finger/hand identification is heuristic and works best with multiple fingers
- Built for the built-in Force Touch trackpad; external trackpads may behave differently

## License

MIT
