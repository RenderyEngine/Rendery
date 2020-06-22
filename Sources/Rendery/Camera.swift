import Numerics

/// A camera from which the content of a scene will be rendered.
public struct Camera {

  /// Initializes a camera.
  public init(
    type projectionType: ProjectionType = .perspective,
    aspectRatio: AspectRatio = .auto
  ) {
    self.projectionType = projectionType
    self.aspectRatio = aspectRatio
  }

  /// The camera's projection type (orthographic or perspective).
  public var projectionType: ProjectionType

  /// A projection type.
  public enum ProjectionType: Equatable {

    /// The orthographic mode.
    ///
    /// An orthographic camera has a fixed depth. It is commonly used to simulate 2D worlds while
    /// dealing with 3D objects.
    case orthographic

    /// The perspective mode.
    ///
    /// A perspective camera has depth, and can be used to represent distance between nearer and
    /// farther objects. It is commonly used to represent realistic 3D worlds.
    case perspective

  }

  /// The camera's aspect ratio.
  public var aspectRatio: AspectRatio

  /// The aspect ratio of a camera.
  public enum AspectRatio: Equatable {

    /// A fixed aspect ratio.
    case fixed(value: Double)

    /// An aspect ratio set automatically to match that of the viewport using the camera.
    case auto

  }

  /// The y-dimension of the frustum's field of view (FOV).
  ///
  /// The field of view is the angle between the camera's position and the edges of the screen onto
  /// which a scene is projected. Typical values are within 45° to 60°.
  public var fovY: Angle = .deg(45.0)

  /// The distance between the camera and the near clipping plane.
  ///
  /// The near clipping plane is the screen onto which a scene is projected. Surfaces in front of
  /// this plane plane are not visible to the camera.
  ///
  /// The distance between the near clipping plane, together with the camera's field of view and an
  /// aspect ratio, determines the dimensions of the frustum within which a scene is viewed (in the
  /// the scene's coordinate system). A frustum viewport should have the same aspect ratio as the
  /// screen viewport that renders it.
  public var nearDistance: Double = 1.0

  /// The distance between the camera and the far clipping plane.
  ///
  /// The far clipping plane represents the limit beyond which a surface is no longer visible to
  /// the camera. In other words, it defines the bottom of the camera's visible frustum.
  public var farDistance: Double = 100.0

  /// The distance from the camera at which objects are in focus.
  ///
  /// With an orthographic projection, this property affects the camera's the orthographic scale,
  /// together with the field of view and aspect ratio. The orthographic scale denotes the portion
  /// of the scene captured by the camera. It's height is given by `tan(fovY / 2) * focusDistance`.
  public var focusDistance: Double = 4.0

  /// Returns the camera's matrix projection matrix.
  ///
  /// The camera projection matrix transforms coordinates from a scene coordinate system (a.k.a.
  /// world coordinate space) onto a 2D clip space.
  ///
  /// - Parameter region: The viewport onto which coordinates should be projected.
  public func projection(onto region: Rectangle) -> Matrix4 {
    var ratio: Double
    if case .fixed(let value) = aspectRatio {
      ratio = value
    } else {
      ratio = region.width / region.height
    }

    switch projectionType {
    case .perspective:
      return perspectiveMatrix(aspectRatio: ratio)
    case .orthographic:
      return orthographicMatrix(aspectRatio: ratio)
    }
  }

  /// Computes a perspective projection matrix.
  private func perspectiveMatrix(aspectRatio: Double) -> Matrix4 {
    // Compute screen coordinates.
    let top = Double.tan(fovY.radians / 2.0) * nearDistance
    let bottom = -top
    let right = top * aspectRatio
    let left = -right

    // Compute the corresponding perspective projection matrix.
    var result = Matrix4.zero
    result[0,0] = (2.0 * nearDistance) / (right - left)
    result[0,3] = (right + left) / (right - left)
    result[1,1] = (2.0 * nearDistance) / (top - bottom)
    result[1,2] = (top + bottom) / (top - bottom)
    result[2,2] = -(farDistance + nearDistance) / (farDistance - nearDistance)
    result[2,3] = (-2.0 * farDistance * nearDistance) / (farDistance - nearDistance)
    result[3,2] = -1.0

    return result
  }

  /// Computes an orthographic projection matrix.
  private func orthographicMatrix(aspectRatio: Double) -> Matrix4 {
    // Compute screen coordinates.
    // let top = fovY.radians / 2.0
    let top = Double.tan(fovY.radians / 2.0) * focusDistance
    let bottom = -top
    let right = top * aspectRatio
    let left = -right

    // Compute the corresponding orthographic projection matrix.
    var result = Matrix4.zero
    result[0,0] = 2.0 / (right - left)
    result[0,3] = -(right + left) / (right - left)
    result[1,1] = 2.0 / (top - bottom)
    result[1,3] = -(top + bottom) / (top - bottom)
    result[2,2] = -2.0 / (farDistance - nearDistance)
    result[2,3] = -(farDistance + nearDistance) / (farDistance - nearDistance);
    result[3,3] = 1.0

    return result
  }

}

extension Camera.AspectRatio: ExpressibleByFloatLiteral {

  public init(floatLiteral value: Double) {
    self = .fixed(value: value)
  }

}
