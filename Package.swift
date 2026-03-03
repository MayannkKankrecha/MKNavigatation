// swift-tools-version: 5.9
// Minimum Swift 5.9 for iOS 16+ NavigationStack support.

import PackageDescription

let package = Package(
    name: "MKNavigatation",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Core navigation library — import this in your feature modules.
        .library(
            name: "MKNavigatation",
            targets: ["MKNavigatation"]
        )
    ],
    targets: [
        // MARK: - Core Library
        // Public API: NavigationRoute, NavigationRouter, NavigationContainer.
        .target(
            name: "MKNavigatation",
            path: "Sources/MKNavigatation"
        ),

        // MARK: - Example (reference only, not shipped as a library product)
        // Shows AppRoute, ViewModels, Views, and App entry-point wiring.
        // To use in an actual app, copy the files in Sources/MKNavigatationExample
        // into your app target — do not link this as a dependency.
        .target(
            name: "MKNavigatationExample",
            dependencies: ["MKNavigatation"],
            path: "Sources/MKNavigatationExample"
        ),

        // MARK: - Unit Tests
        .testTarget(
            name: "MKNavigatationTests",
            dependencies: ["MKNavigatation"],
            path: "Tests/MKNavigatationTests"
        )
    ]
)
