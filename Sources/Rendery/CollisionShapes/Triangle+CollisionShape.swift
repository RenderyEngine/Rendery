extension Triangle: CollisionShape {

  public func collisionDistance(
    with ray: Ray,
    translation: Vector3,
    rotation: Quaternion,
    scale: Vector3,
    isCullingEnabled: Bool
  ) -> Double? {
    let triangle = Matrix4(translation: translation, rotation: rotation, scale: scale) * self
    return triangle.collisionDistance(with: ray, isCullingEnabled: isCullingEnabled)
  }

  /// Returns the distance from a ray’s origin to the point at which it intersects with this
  /// triangle, or nil if there is no intersection.
  ///
  /// - Parameters:
  ///   - ray: The ray with which a collision will be tested.
  ///   - isCullingEnabled: A flag that indicates whether face culling is enabled.
  public func collisionDistance(with ray: Ray, isCullingEnabled: Bool = false) -> Double? {

    // Möller-Trumbore algorithm from "Fast, Minimum Storage Ray/Triangle Intersection", 1997.

    let ab = b - a
    let ac = c - a
    let pvec = ray.direction.cross(ac)
    let det = ab.dot(pvec)

    if isCullingEnabled && det < Double.ulpOfOne {
      // If the determinant is negative, the triangle is back-facing.
      return nil
    } else if abs(det) < Double.ulpOfOne {
      // If the determinant is close to 0, the ray is parallel to the triangle.
      return nil
    }

    let idet = 1.0 / det
    let tvec = ray.origin - a
    let u = tvec.dot(pvec) * idet
    guard (u >= 0.0) && (u <= 1.0)
      else { return nil }

    let qvec = tvec.cross(ab)
    let v = ray.direction.dot(qvec) * idet
    guard (v >= 0.0) && (v <= 1.0)
      else { return nil }

    let t = ac.dot(qvec) * idet
    return t
  }

}
