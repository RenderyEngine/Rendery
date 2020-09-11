/// A section of a pyramid that lies between two parallel planes.
public struct Frustum {

  /// Initializes a frustum with the coordinates of its 8 corners.
  public init(
    nearTopLeft: Vector3,
    nearBottomLeft: Vector3,
    nearBottomRight: Vector3,
    nearTopRight: Vector3,
    farTopLeft: Vector3,
    farBottomLeft: Vector3,
    farBottomRight: Vector3,
    farTopRight: Vector3
  ) {
    self.nearTopLeft      = nearTopLeft
    self.nearBottomLeft   = nearBottomLeft
    self.nearBottomRight  = nearBottomRight
    self.nearTopRight     = nearTopRight
    self.farTopLeft       = farTopLeft
    self.farBottomLeft    = farBottomLeft
    self.farBottomRight   = farBottomRight
    self.farTopRight      = farTopRight
  }

  /// The coordinates of the frustum's top left corner on its near plane.
  public let nearTopLeft: Vector3

  /// The coordinates of the frustum's bottom left corner on its near plane.
  public let nearBottomLeft: Vector3

  /// The coordinates of the frustum's bottom right corner on its near plane.
  public let nearBottomRight: Vector3

  /// The coordinates of the frustum's top right corner on its near plane.
  public let nearTopRight: Vector3

  /// The coordinates of the frustum's top left corner on its far plane.
  public let farTopLeft: Vector3

  /// The coordinates of the frustum's buttom left corner on its far plane.
  public let farBottomLeft: Vector3

  /// The coordinates of the frustum's buttom right corner on its far plane.
  public let farBottomRight: Vector3

  /// The coordinates of the frustum's top right corner on its far plane.
  public let farTopRight: Vector3

  /// The coordinates of the frustum's center.
  public var center: Vector3 {
    var p = nearTopLeft
    p = p + nearBottomLeft
    p = p + nearBottomRight
    p = p + nearTopRight
    p = p + farTopLeft
    p = p + farBottomLeft
    p = p + farBottomRight
    p = p + farTopRight
    return p * 0.125
  }

  /// A collection with all corners of the frustrum.
  public var corners: [Vector3] {
    return [
      nearTopLeft,
      nearBottomLeft,
      nearBottomRight,
      nearTopRight,
      farTopLeft,
      farBottomLeft,
      farBottomRight,
      farTopRight
    ]
  }

  /// Returns a the view-projection matrix from the perspective of a directional light source
  /// oriented with the specified rotation.
  ///
  /// This method computes the matrix that remaps every coordinates contained in the frustum into
  /// a canonical viewing volume oriented in the light's direction. Such a matrix is the product of
  /// an orthographic projection matrix defining the minimum bounding box enclosing the frustum,
  /// oriented in the light's direction, and a view matrix that rempas every scene coordinate into
  /// light space.
  ///
  /// - Parameter rotation: The light's rotation, in the scene coordinate space.
  public func lightViewProjMatrix(rotation: Quaternion) -> Matrix4 {
    // Cache compute properties.
    let corners = self.corners

    // Compute the dimensions of a bounding box that encloses the frustum in light space.
    let x = rotation * Vector3.unitX
    var xMin = corners[0].dot(x)
    var xMax = xMin

    let y = rotation * Vector3.unitY
    var yMin = corners[0].dot(y)
    var yMax = yMin

    let z = y.cross(x)
    var zMin = corners[0].dot(z)
    var zMax = zMin

    for i in 1 ..< 8 {
      let dx = corners[i].dot(x)
      if dx < xMin {
        xMin = dx
      } else if dx > xMax {
        xMax = dx
      }

      let dy = corners[i].dot(y)
      if dy < yMin {
        yMin = dy
      } else if dy > yMax {
        yMax = dy
      }

      let dz = corners[i].dot(z)
      if dz < zMin {
        zMin = dz
      } else if dz > zMax {
        zMax = dz
      }
    }

    let hWidth  = (xMax - xMin) * 0.5
    let hHeight = (yMax - yMin) * 0.5
    let hDepth  = (zMax - zMin) * 0.5

    // Compute the light's orthographic projection matrix.
    let proj = Matrix4.orthographic(
      top   : hHeight,
      bottom: -hHeight,
      right : hWidth,
      left  : -hWidth,
      far   : hDepth * 2.0,
      near  : 0.0)

    // Compute the center of the light's frustum in scene space.
    var obbCenter = Vector3.zero
    obbCenter = obbCenter + x * (xMin + xMax) * 0.5
    obbCenter = obbCenter + y * (yMin + yMax) * 0.5
    obbCenter = obbCenter + z * (zMin + zMax) * 0.5

    // Compute the light's view matrix, which moves scene coordinates into light space.
    let translation = obbCenter - z * hDepth
    let view = Matrix4.lookAt(from: translation, to: obbCenter).inverted

    // Compute the light's view-projection matrix.
    return proj * view
  }

}
