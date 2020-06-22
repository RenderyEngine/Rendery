/// A structure that represents a half-line that extends indefinitely in one direction.
public struct Ray {

  /// Initializes a ray with its origin and the direction toward which it shoots.
  ///
  /// - Parameters:
  ///   - origin: The ray's origin.
  ///   - direction: The ray's direction, as a unit vector.
  public init(origin: Vector3, direction: Vector3) {
    self.origin = origin
    self.direction = direction
  }

  /// The ray's origin.
  public var origin: Vector3

  /// The ray's direction, as a unit vector.
  public var direction: Vector3

  /// Returns the distance from the ray's origin to the point at which it intersects with the
  /// thes specied collision shape, or `nil` if there is no intersection.
  ///
  /// The method accepts a set of transform properties to project the shape into the same space as
  /// the ray. The reason is that collision shapes are defined in their own local space, whereas
  /// collision detection is typically achieved in the scene coordinate space.
  ///
  /// - Parameters:
  ///   - shape: The shape with which a collision will be tested.
  ///   - translation: The translation required to project the shape into the ray's spacce.
  ///   - rotation: The rotation required to project the shape into the ray's space.
  ///   - scale: The scale required to project the shape into the ray's space.
  ///   - isCullingEnabled: A flag that indicates whether face culling is enabled. On side-shapes,
  ///     this parameter specifies whether face culling is enabled, in which case a collision will
  ///     not be detected unless the ray hits the front of the shape.
  public func collisionDistance<S>(
    with shape: S,
    translation: Vector3 = .zero,
    rotation: Quaternion = .identity,
    scale: Vector3 = .unitScale,
    isCullingEnabled: Bool = false
  ) -> Double? where S: CollisionShape {
    return shape.collisionDistance(
      with: self,
      translation: translation,
      rotation: rotation,
      scale: scale,
      isCullingEnabled: isCullingEnabled)
  }

}
