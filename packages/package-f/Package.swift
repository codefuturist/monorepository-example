// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PackageF",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PackageF",
            targets: ["PackageF"]
        ),
    ],
    targets: [
        .target(
            name: "PackageF"
        ),
        .testTarget(
            name: "PackageFTests",
            dependencies: ["PackageF"]
        ),
    ]
)
