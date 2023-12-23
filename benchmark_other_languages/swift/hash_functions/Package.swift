// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hash_functions",
    products: [
        .executable(
            name: "hash_functions",
            targets: ["hash_functions"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "hash_functions",
            dependencies: [])
    ]
)
