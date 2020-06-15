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
