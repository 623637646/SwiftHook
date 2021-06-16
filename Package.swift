// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftHook",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftHook",
            targets: ["SwiftHook"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "libffi_iOS", url: "https://github.com/623637646/libffi.git", from: "3.3.6-iOS")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        // Source Code
        .target(
            name: "SwiftHookOCSources",
            dependencies: ["libffi_iOS"],
            path: "SwiftHook/Classes/OCSources",
            publicHeadersPath: ""),
        .target(
            name: "SwiftHook",
            dependencies: ["libffi_iOS", "SwiftHookOCSources"],
            path: "SwiftHook/Classes",
            exclude: ["OCSources"]),
    ]
)
