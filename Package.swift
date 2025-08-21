// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NextPangeaSetup",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "NPOptions",
            targets: [
                "NPOptions"
            ]),
        .library(
            name: "NPCommon",
            targets: [
                "NPCommon"
            ]),
        .executable(
            name: "npup",
            targets: [
                "NPSetup"
            ]),
        .executable(
            name: "np",
            targets: [
                "NPDriver"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-tools-support-core.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", exact: "5.4.0"),
    ],
    targets: [
        .target(
            name: "NPOptions"),
        .target(
            name: "NPCommon",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ]),
        .executableTarget(
            name: "NPSetup",
            dependencies: [
                "NPCommon",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .executableTarget(
            name: "NPDriver",
            dependencies: [
                "NPCommon"
            ]),
    ]
)
