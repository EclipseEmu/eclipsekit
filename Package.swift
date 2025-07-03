// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EclipseKit",
    platforms: [.iOS(.v13), .macOS(.v13)],
    products: [
        .library(name: "EclipseKit", targets: ["EclipseKit"]),
    ],
	dependencies: [
		.package(url: "https://github.com/magnetardev/atomic-compat", .upToNextMajor(from: "1.0.0"))
	],
    targets: [
        .target(
			name: "EclipseKit",
			dependencies: [.product(name: "AtomicCompat", package: "atomic-compat")]
		),
        .testTarget(name: "EclipseKitTests", dependencies: ["EclipseKit"]),
    ]
)
