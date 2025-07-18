// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EclipseKit",
    platforms: [.iOS(.v14), .macOS(.v11)],
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
