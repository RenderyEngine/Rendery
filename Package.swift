// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rendery",
  products: [
    .executable(name: "UsageExample", targets: ["UsageExample"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-numerics", from: "0.0.5"),
  ],
  targets: [
    // Swift targets.
    .target(name: "UsageExample", dependencies: ["Rendery"]),
    .target(
      name: "Rendery",
      dependencies: ["CGLFW", "Cstb", "Numerics"],
      linkerSettings: [
        .linkedFramework("OpenGL"),
      ]
    ),

    // C targets.
    .target(name: "Cstb", dependencies: []),

    // System libraries.
    .systemLibrary(name: "CGLFW", pkgConfig: "glfw3"),
    // .systemLibrary(name: "CGLFW"),

    // Test targets.
    .testTarget(name: "RenderyTests", dependencies: ["Rendery"]),
  ])
