// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KainianSetup",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "KNOptions",
            targets: [
                "KNOptions"
            ]),
        .library(
            name: "KNCommon",
            targets: [
                "KNCommon"
            ]),
        .executable(
            name: "knup",
            targets: [
                "KNSetup"
            ]),
        .executable(
            name: "kn",
            targets: [
                "KNDriver"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-tools-support-core.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", exact: "5.4.0"),
    ],
    targets: [
        .target(
            name: "KNOptions"),
        .target(
            name: "KNCommon",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ]),
        .executableTarget(
            name: "KNSetup",
            dependencies: [
                "KNCommon",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .executableTarget(
            name: "KNDriver",
            dependencies: [
                "KNCommon"
            ]),
    ]
)
