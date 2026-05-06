// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JPRouterKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "JPRouterKit",
            targets: ["JPRouterKit"]),
    ],
    targets: [
        .target(
            name: "JPRouterKit",
            path: "JPRouter/Sources/JPRouter"),
    ]
)

