// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftHook",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftHook",
            targets: ["SwiftHook"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/623637646/libffi.git", from: "3.4.7")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        // Source Code
        .target(
            name: "SwiftHookOCSources",
            dependencies: [.product(name: "libffi_apple", package: "libffi")],
            path: "SwiftHook/Classes/OCSources",
            publicHeadersPath: ""),
        .target(
            name: "SwiftHook",
            dependencies: [.product(name: "libffi_apple", package: "libffi"), "SwiftHookOCSources"],
            path: "SwiftHook/Classes",
            exclude: ["OCSources"])
    ]
)
