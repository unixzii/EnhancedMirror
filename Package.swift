// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "EnhancedMirror",
    platforms: [.macOS(.v10_15), .iOS(.v12), .tvOS(.v12), .watchOS(.v5), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EnhancedMirror",
            targets: ["EnhancedMirror"]
        ),
    ],
    dependencies: [
        // TODO: Remove this when Xcode 15 released.
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
    ],
    targets: [
        // Macro implementation that performs the source transformation for mirror.
        .macro(
            name: "EnhancedMirrorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes the macros and runtime APIs.
        .target(name: "EnhancedMirror", dependencies: ["EnhancedMirrorMacros"]),

        // Unit tests.
        .testTarget(
            name: "EnhancedMirrorMacroTests",
            dependencies: [
                "EnhancedMirrorMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "EnhancedMirrorTests",
            dependencies: [
                "EnhancedMirror",
            ]
        ),
    ]
)
