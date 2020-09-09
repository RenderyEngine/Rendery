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

  /// The frustum's top left coordinates on its near plane.
  public let nearTopLeft: Vector3

  /// The frustum's bottom left coordinates on its near plane.
  public let nearBottomLeft: Vector3

  /// The frustum's bottom right coordinates on its near plane.
  public let nearBottomRight: Vector3

  /// The frustum's top right coordinates on its near plane.
  public let nearTopRight: Vector3

  /// The frustum's top left coordinates on its far plane.
  public let farTopLeft: Vector3

  /// The frustum's buttom left coordinates on its far plane.
  public let farBottomLeft: Vector3

  /// The frustum's buttom right coordinates on its far plane.
  public let farBottomRight: Vector3

  /// The frustum's top right coordinates on its far plane.
  public let farTopRight: Vector3

}
