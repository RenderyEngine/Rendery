import CGLFW

/// A drawing environment to render view elements.
public struct ViewRenderer: ViewDrawingContext {

  /// Initializes a view renderer.
  internal init() {
  }

  /// The dimensions of the viewport, in pixels.
  public internal(set) var dimensions: Vector2 = .zero {
    didSet {
      if dimensions != oldValue {
        self.projection = Matrix4.orthographic(
          top   : dimensions.y,
          bottom: 0.0,
          right : dimensions.x,
          left  : 0.0,
          far   : 0.0,
          near  : 1.0)
      }
    }
  }

  /// The current position of the renderer's pen.
  public var penPosition: Vector2 = .zero

  /// The default font face that is used to draw text.
  public var defaultFontFace: FontFace?

  /// An orthographic projection matrix that translates view and control coordinates into the
  /// viewport's clip space.
  private var projection: Matrix4 = .identity

  public func fill(rectangle: Rectangle, color: Color) {
    let program = ViewRenderer.quadProgram
    try! program.load()
    program.install()

    let transform = Matrix4(translation: Vector3(
      x: penPosition.x,
      y: dimensions.y - penPosition.y - rectangle.dimensions.y,
      z: 0.0))

    program.assign(projection * transform, to: "mvp")
    program.assign(Texture.default, to: "texture", textureUnit: 0)
    program.assign(false, to: "shouldSampleQuadTexture")
    program.assign(color, to: "multiply", discardingAlpha: false)

    ViewRenderer.quad.load()
    ViewRenderer.quad.update(rectangle)
    ViewRenderer.quad.draw()
  }

  public func draw(string: String, face: FontFace?, color: Color, scale: Double) {
    guard let textFace = face ?? defaultFontFace
      else { return }

    let program = ViewRenderer.quadProgram
    try! program.load()
    program.install()

    ViewRenderer.quad.load()

    let transform = Matrix4(
      translation: Vector3(
        x: penPosition.x,
        y: self.dimensions.y - penPosition.y - textFace.height * scale,
        z: 0.0),
      rotation: .identity,
      scale: Vector3(x: scale, y: scale, z: scale))

    program.assign(projection * transform, to: "mvp")
    program.assign(true, to: "shouldSampleQuadTexture")
    program.assign(color, to: "multiply", discardingAlpha: false)

    glActiveTexture(GL.TEXTURE0)

    let wasAlphaPremultiplied = AppContext.shared.renderContext.isAlphaPremultiplied
    AppContext.shared.renderContext.isAlphaPremultiplied = false
    defer {
      AppContext.shared.renderContext.isAlphaPremultiplied = wasAlphaPremultiplied
    }

    var xOffset = 0.0
    for character in string {
      // Generate a glyph.
      guard let glyph = textFace.glyph(for: character)
        else { continue }

      // Update the quad's vertices.
      let origin = Vector2(
        x: glyph.bearing.x + xOffset,
        y: -(glyph.size.y - glyph.bearing.y))
      ViewRenderer.quad.update(Rectangle(origin: origin, dimensions: glyph.size))

      // Bind the glyph texture.
      if let texture = glyph.texture {
        texture.load()
        glBindTexture(GL.TEXTURE_2D, texture.handle)
      }

      // Draw the glyph.
      ViewRenderer.quad.draw()

      xOffset += glyph.advance / 64.0
    }
  }

  private static var quad = Quad()

  private static var quadProgram = GLSLProgram(delegate: QuadProgram())

}

// MARK: Geometry

/// A flat, quadrilateral geometry that can be used to draw 2D elements.
private final class Quad: GraphicsResource {

  internal func update(_ rectangle: Rectangle) {
    let (lx, ly) = (Float(rectangle.minX), Float(rectangle.minY))
    let (gx, gy) = (Float(rectangle.maxX), Float(rectangle.maxY))

    let data: [Float] = [
      // Positions  // UVs
      lx, gy,       0.0, 0.0, // top left
      lx, ly,       0.0, 1.0, // bottom left
      gx, ly,       1.0, 1.0, // bottom right
      lx, gy,       0.0, 0.0, // top left
      gx, ly,       1.0, 1.0, // bottom right
      gx, gy,       1.0, 0.0, // top right
    ]

    glBindBuffer(GL.ARRAY_BUFFER, vboID)
    glBufferSubData(GL.ARRAY_BUFFER, 0, MemoryLayout<Float>.stride * data.count, data)
    glBindBuffer(0, vboID)
  }

  internal func draw() {
    assert(state == .loaded)

    glBindVertexArray(vaoID)
    glDrawArrays(GL.TRIANGLES, 0, 6)
    glBindVertexArray(0)
  }

  internal var state: GraphicsResourceState = .unloaded

  internal func load() {
    guard state != .loaded
      else { return }

    assert(AppContext.shared.isInitialized)
    assert(glfwGetCurrentContext() != nil)

    // Upload the vertex data into a VAO and VBO.
    glGenVertexArrays(1, &vaoID)
    assert(vaoID != 0)
    glBindVertexArray(vaoID)

    glGenBuffers(1, &vboID)
    assert(vboID != 0)
    glBindBuffer(GL.ARRAY_BUFFER, vboID)
    glBufferData(GL.ARRAY_BUFFER, MemoryLayout<Float>.stride * 6 * 4, nil, GL.DYNAMIC_DRAW)

    glEnableVertexAttribArray(0)
    glVertexAttribPointer(0, 4, GL.FLOAT, 0, GL.Size(4 * MemoryLayout<Float>.stride), nil)

    glBindBuffer(GL.ARRAY_BUFFER, 0)
    glBindVertexArray(0)

    state = .loaded
    LogManager.main.log("Quad '\(address(of: self))' successfully loaded.", level: .debug)

    // Bind the quad's lifetime to the app context.
    AppContext.shared.graphicsResourceManager.store(self)
  }

  internal func unload() {
    glDeleteBuffers(1, &vboID)
    glDeleteVertexArrays(1, &vaoID)
    LogManager.main.log("Quad '\(address(of: self))' successfully unloaded.", level: .debug)

    vaoID = 0
    vboID = 0
    state = .unloaded
  }

  /// The ID of OpenGL's vertex array.
  private var vaoID: GL.UInt = 0

  /// The ID of OpenGL's vertex buffer.
  private var vboID: GL.UInt = 0

  deinit {
    // Delete the quad's buffers from the GPU memory.
    glDeleteBuffers(1, &vboID)
    glDeleteVertexArrays(1, &vaoID)
  }

}

// MARK: Shader

private struct QuadProgram: GLSLProgramDelegate {

  struct Parameters {

    let texture: Texture

    let shouldSampleQuadTexture: Bool

    let multiply: Color

    let mvp: Matrix4

  }

  var vertexSource: String { _textureQuadVertexSource }

  var fragmentSource: String { _textureQuadFragmentSource }

}

private let _textureQuadVertexSource = """
#version 330 core
layout (location = 0) in vec4 vertex;

uniform mat4 mvp;

out vec2 fragmentUVs;

void main() {
  gl_Position = mvp * vec4(vertex.xy, 0.0, 1.0);
  fragmentUVs = vertex.zw;
}
"""

private let _textureQuadFragmentSource = """
#version 330 core
in vec2 fragmentUVs;

uniform sampler2D quadTexture;
uniform bool shouldSampleQuadTexture;
uniform vec4 multiply;

out vec4 finalColor;

void main() {
  vec4 texel = shouldSampleQuadTexture
    ? vec4(1.0, 1.0, 1.0, texture(quadTexture, fragmentUVs).r)
    : texture(quadTexture, fragmentUVs);
  finalColor = texel * multiply;
}
"""
