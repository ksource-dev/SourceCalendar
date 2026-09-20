// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SourceCalendar",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .watchOS(.v27),
        .tvOS(.v27),
        .visionOS(.v27)
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
