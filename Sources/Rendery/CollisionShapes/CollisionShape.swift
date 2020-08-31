/// A collision shape, defining a volume for collision testing.
public protocol CollisionShape {

  /// Returns the distance from a ray's origin to the point at which it intersects with this shape,
  /// or `nil` if there is no intersection.
  ///
  /// The method accepts a set of transform properties to project the shape into the same space as
  /// the ray. The reason is that collision shapes are defined in their own local space, whereas
  /// collision detection is typically achieved in the scene coordinate space.
  ///
  /// - Parameters:
  ///   - ray: The ray with which a collision will be tested.
  ///   - translation: The translation required to project the shape into the ray's spacce.
  ///   - rotation: The rotation required to project the shape into the ray's space.
  ///   - scale: The scale required to project the shape into the ray's space.
  ///   - isCullingEnabled: A flag that indicates whether face culling is enabled. On sided shapes,
  ///     this parameter specifies whether collisions that hit back faces should be reported.
  func collisionDistance(
    with ray: Ray,
    translation: Vector3,
    rotation: Quaternion,
    scale: Vector3,
    isCullingEnabled: Bool
  ) -> Double?

}
