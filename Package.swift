// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "USBCleaner",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "USBCleaner",
            targets: ["USBCleaner"]),
    ],
    targets: [
        .executableTarget(
            name: "USBCleaner"),
        .testTarget(
            name: "USBCleanerTests",
            dependencies: ["USBCleaner"]),
    ]
)
