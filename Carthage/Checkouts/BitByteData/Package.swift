// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "BitByteData",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "BitByteData",
            targets: ["BitByteData"])
    ],
    targets: [
        .target(name: "BitByteData", path: "Sources"),
        .testTarget(name: "BitByteDataTests", dependencies: ["BitByteData"]),
        .testTarget(name: "BitByteDataBenchmarks", dependencies: ["BitByteData"])
    ],
    swiftLanguageVersions: [.v5]
)
