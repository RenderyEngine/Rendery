extension Sphere: CollisionShape {

  public func collisionDistance(
    with ray: Ray,
    translation: Vector3,
    rotation: Quaternion,
    scale: Vector3,
    isCullingEnabled: Bool
  ) -> Double? {
    assert((scale.x == scale.y) && (scale.y == scale.z))

    let l = ray.origin - (origin + translation)
    let r = radius * scale.x

    let a = ray.direction.dot(ray.direction)
    let b = ray.direction.dot(l) * 2.0
    let c = l.dot(l) - (r * r)

    guard let (x0, x1) = solveQuatratic(a: a, b: b, c: c)
      else { return nil }

    if x0 < 0.0 {
      return isCullingEnabled || (x1 < 0.0)
        ? nil
        : x1
    } else {
      return x0
    }
  }

  /// Returns whether the sphere intersects with the specified axis-aligned box.
  ///
  /// - Parameter box: The box with which intersection will be tested.
  public func intersects(with box: AxisAlignedBox) -> Bool {
    return origin.squaredDistance(to: box) < radius * radius
  }

}
