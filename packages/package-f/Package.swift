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
        .executable(
            name: "package-f",
            targets: ["PackageFCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "PackageF"
        ),
        .executableTarget(
            name: "PackageFCLI",
            dependencies: [
                "PackageF",
                .product(name: "Rainbow", package: "Rainbow")
            ]
        ),
        .testTarget(
            name: "PackageFTests",
            dependencies: ["PackageF"]
        ),
    ]
)
