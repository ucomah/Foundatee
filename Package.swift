// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "Foundatee"

let package = Package(
    name: packageName,
    platforms: [.iOS(.v10), .macOS(.v10_13)],
    products: [
        .library(
            name: packageName,
            targets: ["Foundatee"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: packageName,
            dependencies: [
                "CodableExtensions",
                "PropertyWrappers",
                "Utility",
            ]
        ),
        .target(name: "CodableExtensions"),
        .target(name: "PropertyWrappers"),
        .target(
            name: "Utility",
            dependencies: ["PropertyWrappers"]
        ),
        .testTarget(
            name: "FoundateeTests",
            dependencies: ["Foundatee"]
        ),
    ]
)
