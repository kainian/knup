// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NextPangeaSetup",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "NPSCore",
            targets: [
                "NPSCore"
            ]),
        .library(
            name: "NPSInstaller",
            targets: [
                "NPSInstaller"
            ]),
        .executable(
            name: "npup",
            targets: [
                "NPSetup"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-tools-support-core.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", exact: "5.4.0"),
    ],
    targets: [
        .target(
            name: "NPSCore",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ]),
        .target(
            name: "NPSInstaller",
            dependencies: [
                "NPSCore",
                .product(name: "Yams", package: "Yams"),
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ]),
        .executableTarget(
            name: "NPSetup",
            dependencies: [
                "NPSInstaller",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
    ]
)
