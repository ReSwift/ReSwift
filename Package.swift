// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ReSwift",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(name: "ReSwift", targets: ["ReSwift"])
    ],
    targets: [
        .target(
            name: "ReSwift",
            path: "ReSwift"
        ),
        .testTarget(
            name: "ReSwiftTests",
            dependencies: ["ReSwift"],
            path: "ReSwiftTests"
        )
    ]
)
