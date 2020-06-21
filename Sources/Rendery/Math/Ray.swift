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

  /// Returns whether this ray intersects with the specified box.
  ///
  /// The parameter `aabb` is assumed to be an axis-aligned box defined in some local space (e.g.,
  /// the coordinate space of a mesh's vertices). If the ray is defined in another space, then you
  /// should provide transform parameters to project the box's coordinates, effectively computing
  /// a so-called "OBB".
  ///
  /// - Parameters:
  ///   - aabb: A naxis-aligned box specifying the cuboid with which a collision will be tested.
  ///   - translation: The translation to apply on `aabb`'s coordinates.
  ///   - rotation: The rotation to apply on `aabb`'s coordinates.
  ///   - scale: The rotation to apply on `aabb`'s coordinates.
  ///
  ///   - transform: A transformation matrix that is applied to `aabb` to obtain the corresponding
  ///     (translated, scaled and) oriented bounding box (a.k.a., OBB).
  ///
  /// - Returns: The nearest point at which the ray intersects with the box, or `nil` if it does
  ///   not intersect with it.
  public func collisionPoint(
    with aabb: AxisAlignedBox,
    translation: Vector3 = .zero,
    rotation: Quaternion = .identity,
    scale: Vector3 = .unitScale
  ) -> Vector3? {
    let delta = translation - origin
    var tmin: Double
    var tmax: Double

    let rotationMatrix = Matrix4(rotation: rotation)
    let scaledAABB = aabb.scaled(by: scale)

    // Test intersection with the 2 planes perpendicular to the OBB's x-axis.
    do {
      let x = Vector3(x: rotationMatrix[0,0], y: rotationMatrix[1,0], z: rotationMatrix[2,0])
      let ex = x.dot(delta)
      let fx = direction.dot(x)
      if abs(fx) < Double.defaultTolerance {
        // The ray is almost parallel to the near/far planes.
        if (-ex + scaledAABB.minX > 0.0) || (-ex + scaledAABB.maxX < 0.0) {
          return nil
        }
      }

      tmin = (ex + scaledAABB.minX) / fx
      tmax = (ex + scaledAABB.maxX) / fx
      if tmin > tmax {
        swap(&tmin, &tmax)
      }
    }

    // Test intersection with the 2 planes perpendicular to the OBB's y-axis.
    do {
      let y = Vector3(x: rotationMatrix[0,1], y: rotationMatrix[1,1], z: rotationMatrix[2,1])
      let ey = y.dot(delta)
      let fy = direction.dot(y)
      if abs(fy) < Double.defaultTolerance {
        // The ray is almost parallel to the near/far planes.
        if (-ey + scaledAABB.minY > 0.0) || (-ey + scaledAABB.maxY < 0.0) {
          return nil
        }
      } else {
        var tymin = (ey + scaledAABB.minY) / fy
        var tymax = (ey + scaledAABB.maxY) / fy
        if tymin > tymax {
          swap(&tymin, &tymax)
        }

        if tymin > tmin {
          tmin = tymin
        }
        if tymax < tmax {
          tmax = tymax
        }
        if tmin > tmax {
          return nil
        }
      }
    }

    // Test intersection with the 2 planes perpendicular to the OBB's z-axis.
    do {
      let z = Vector3(x: rotationMatrix[0,2], y: rotationMatrix[1,2], z: rotationMatrix[2,2])
      let ez = z.dot(delta)
      let fz = direction.dot(z)
      if abs(fz) < Double.defaultTolerance {
        // The ray is almost parallel to the near/far planes.
        if (-ez + scaledAABB.minZ > 0.0) || (-ez + scaledAABB.maxZ < 0.0) {
          return nil
        }
      } else {
        var tzmin = (ez + scaledAABB.minZ) / fz
        var tzmax = (ez + scaledAABB.maxZ) / fz
        if tzmin > tzmax {
          swap(&tzmin, &tzmax)
        }

        if tzmin > tmin {
          tmin = tzmin
        }
        if tzmax < tmax {
          tmax = tzmax
        }
        if tmin > tmax {
          return nil
        }
      }
    }

    return origin + direction * tmin
  }

}
