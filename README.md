# Rendery

Rendery is a modern, type-safe 2D/3D rendering engine, written in Swift.
It is designed to provide a simple and intuitive programming interface to write applications using computer graphics, such as video games and data visualization tools.

## Motivation

_Why another rendering engine?_

Rendery is born from the frustration of not finding the necessary tools to develop a video game with Swift, beyond the confinement of a purely macOS/iOS ecosystem.
Swift is a relatively young language that does not enjoy the same variety of libraries and tools that exist for other, more established languages yet, outside of Apple's ecosystem.
As a result, writing portable applications with Swift is a little challenging.
Rendery is a modest attempt to address this issue in the context of graphics rendering.

## Design Goals

The main design goals of Rendery are the following:

* __Intuitive__:
  Rendery aims to be as simple and intuitive as possible.
  This means that it should provide high-level, human-understandable abstractions over the technical aspects of computer graphics rendering.
* __Modern__:
  Rendery aims to offer a "modern" approach to the design of a rendering engine, by choosing architectural patterns that promote ease of use while maintaining type and memory-safety.
* __Self-contained__:
  Rendery aims to be a "self-contained" library and to maintain its external dependencies to a bare minimum.
  Using Rendery should as easy as adding `import Rendery` at the top of your file.
* __Portable__:
  Rendery aims to provide a cross-platform alternative to Apple's [SpriteKit](https://developer.apple.com/documentation/spritekit)/[SceneKit](https://developer.apple.com/documentation/scenekit) frameworks.

## Installation

Rendery is distributed in the form of a Swift package and can be installed via the [Swift Package Manager](https://swift.org/package-manager/) (SPM).
Start by creating a new package (unless you already have one):

```bash
mkdir MyAwesomeProject
cd MyAwesomeProject
swift package init --type executable
```

Then, add Rendery as a dependency to your package, from your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
  name: "MyAwesomeProject",
  dependencies: [
    .package(url: "https://github.com/RenderyEngine/Rendery", .branch("master")),
  ],
  targets: [
    .target(name: "MyAwesomeProject", dependencies: ["Rendery"]),
  ]
)
```

> Rendery is still under active development and hasn't reached a release yet.
> In the meantime, referring to the master branch guarantees that you'll always pull the latest version.

Rendery has two system dependencies that need to be installed on your system:
* [GLFW](https://www.glfw.org), which is used to manage windows and handle input events.
* [FreeType](https://www.freetype.org), which is used to render fonts.

SPM should be able to locate both of them using pgk-config.
If everything goes well, you should be able to import Rendery in your own project:

```swift
import Rendery

// Your amazing code goes here
```
