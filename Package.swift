// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SourceCalendar",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .watchOS(.v26),
        .tvOS(.v26),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "SourceCalendar",
            targets: ["SourceCalendar"]
        ),
    ],
    targets: [
        .target(
            name: "SourceCalendar"
        ),
        .testTarget(
            name: "SourceCalendarTests",
            dependencies: ["SourceCalendar"]
        ),
    ]
)
