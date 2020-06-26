/// An object that can render views and controls on top of a scene.
public struct ViewRenderer {

  internal init() {
    try! shader.load()
  }

  /// The current position of the renderer's pen.
  public var penPosition: Vector2 {
    get {
      return Vector2(
        x: (transform[0,3] + 1.0) * 2.0,
        y: (-transform[1,3] + 1.0) * 2.0)
    }

    set {
      transform[0,3] = newValue.x * 2.0 - 1
      transform[1,3] = -newValue.y * 2.0 - 1
    }
  }

  public let shader: GLSLProgram = .flat

  private var transform: Matrix4 = ViewRenderer.initialTransform

  private static let initialTransform = Matrix4(
    translation: Vector3(x: -1.0, y: -1.0, z: 0.0),
    rotation: .identity,
    scale: .unitScale * 2.0)

  internal mutating func render<V>(view: V) where V: View {
    // Disable depth testing.
    let wasDepthTestingEnabled = AppContext.shared.isDepthTestingEnabled
    AppContext.shared.isDepthTestingEnabled = false

    shader.install()
    view.render(into: &self)

    // Restore depth testing.
    AppContext.shared.isDepthTestingEnabled = wasDepthTestingEnabled
  }

  /// Draws the specified mesh with the renderer's current settings.
  public func draw(mesh: Mesh) {
    let context: GLSLFlatColorProgram.Parameters = (color: .white, mvp: transform)
    withUnsafePointer(to: context) { shader.bind($0) }

    mesh.draw()
  }

  internal static var _rectangle: Mesh?

  internal static var rectangle: Mesh {
    if _rectangle == nil {
      _rectangle = Mesh.rectangle(Rectangle(origin: .zero, dimensions: Vector2(x: 1.0, y: 1.0)))
    }

    _rectangle!.load()
    return _rectangle!
  }

}
