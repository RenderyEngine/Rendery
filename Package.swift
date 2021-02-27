// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rendery",
  products: [
    .executable(name: "UsageExample", targets: ["UsageExample"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-numerics", from: "0.0.5"),
    .package(name: "GL", url:"https://github.com/kelvin13/swift-opengl.git", .branch("master"))
  ],
  targets: [
    // Swift targets.
    .target(name: "UsageExample", dependencies: ["Rendery"]),
    .target(
      name: "Rendery",
      dependencies: ["GL", "CSTBImage", "CGLFW", "CGlad", "CFreeType", "Cgltf", .product(name: "Numerics", package: "swift-numerics")]
      // linkerSettings: [
      //   .linkedFramework("OpenGL"),
      // ]
    ),

    // C targets.
    .target(name: "CSTBImage", dependencies: []),
    .target(name: "Cgltf", dependencies: []),
    .target(name: "CGlad", dependencies: []),

    // System libraries.
    .systemLibrary(name: "CFreeType", pkgConfig: "freetype2"),
    .systemLibrary(name: "CGLFW", pkgConfig: "glfw3"),

    // Test targets.
    .testTarget(name: "RenderyTests", dependencies: ["Rendery"]),
  ])
