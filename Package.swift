// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ReSwift",
    products: [
      .library(name: "ReSwift", targets: ["ReSwift"])
    ],
    targets: [
      .target(name: "ReSwift", path: "ReSwift")
    ]
)
