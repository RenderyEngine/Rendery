extension AxisAlignedBox: CollisionShape {

  public func collisionDistance(
    with ray: Ray,
    translation: Vector3,
    rotation: Quaternion,
    scale: Vector3,
    isCullingEnabled: Bool
  ) -> Double? {
    let delta = translation - ray.origin
    var tmin: Double
    var tmax: Double

    let rotationMatrix = Matrix4(rotation: rotation)
    let scaledAABB = scaled(by: scale)

    // Test intersection with the 2 planes perpendicular to the OBB's x-axis.
    do {
      let x = Vector3(x: rotationMatrix[0,0], y: rotationMatrix[1,0], z: rotationMatrix[2,0])
      let ex = x.dot(delta)
      let fx = ray.direction.dot(x)
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
      let fy = ray.direction.dot(y)
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
      let fz = ray.direction.dot(z)
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

    return tmin
  }

}
