// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cryptoless",
    platforms: [
        .iOS(.v13), .macOS(.v12), .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Cryptoless",
            targets: ["Cryptoless"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Modularize-Packages/ReactiveX.git", branch: "main"),
        .package(url: "https://github.com/Modularize-Packages/Signer.git", branch: "main"),
        .package(url: "https://github.com/Flight-School/AnyCodable", .upToNextMajor(from: "0.6.5"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Cryptoless",
            dependencies: [
                .byName(name: "ReactiveX"),
                .byName(name: "Signer"),
                .byName(name: "AnyCodable"),
            ]),
        .testTarget(
            name: "CryptolessTests",
            dependencies: ["Cryptoless"]),
    ]
)
