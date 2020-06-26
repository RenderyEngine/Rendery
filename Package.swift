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
      dependencies: ["CSTBImage", "CGLFW", "CFreeType", "Cgltf", "Numerics"],
      linkerSettings: [
        .linkedFramework("OpenGL"),
      ]
    ),

    // C targets.
    .target(name: "CSTBImage", dependencies: []),
    .target(name: "Cgltf", dependencies: []),

    // System libraries.
    .systemLibrary(name: "CFreeType", pkgConfig: "freetype2"),
    .systemLibrary(name: "CGLFW", pkgConfig: "glfw3"),
    // .systemLibrary(name: "CGLFW"),

    // Test targets.
    .testTarget(name: "RenderyTests", dependencies: ["Rendery"]),
  ])
