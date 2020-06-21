import Numerics

/// A structure that represents a quaternion.
///
/// A quaternion is a mathematical structure that is suitable to represent rotations in a 3D space.
/// Their internal representation is akin to a 4-components vector.
public struct Quaternion: Hashable {

  /// Initializes a quaternion with components specified as floating-point values.
  public init(w: Double, x: Double, y: Double, z: Double) {
    self.w = w
    self.x = x
    self.y = y
    self.z = z
  }

  /// Initializes a union quaternion from an axis-angle representation.
  ///
  /// - Parameters:
  ///   - axis: The rotation axis as a normalized 3D vector.
  ///   - angle: The magnitude of rotation.
  public init(axis: Vector3, angle: Angle) {
    let halfAngle = angle.radians * 0.5
    let s = Double.sin(halfAngle)

    self.w = Double.cos(halfAngle)
    self.x = axis.x * s
    self.y = axis.y * s
    self.z = axis.z * s
  }

  /// Initializes a unit quaternion from Euler angles.
  ///
  /// The rotations are combined following a yaw (Z), then pitch (Y), then roll (X) order.
  ///
  /// - Parameters:
  ///   - yaw: The yaw angle.
  ///   - pitch: The pitch angle.
  ///   - roll: The roll angle.
  public init(yaw: Angle, pitch: Angle, roll: Angle) {
    let cy = Double.cos(yaw.radians * 0.5)
    let sy = Double.sin(yaw.radians * 0.5)
    let cp = Double.cos(pitch.radians * 0.5)
    let sp = Double.sin(pitch.radians * 0.5)
    let cr = Double.cos(roll.radians * 0.5)
    let sr = Double.sin(roll.radians * 0.5)

    self.w = cr * cp * cy + sr * sp * sy
    self.x = sr * cp * cy - cr * sp * sy
    self.y = cr * sp * cy + sr * cp * sy
    self.z = cr * cp * sy - sr * sp * cy
  }

  /// Initializes a unit quaternion from a rotation matrix.
  ///
  /// - Parameter matrix: A rotation matrix.
  public init(matrix: Matrix4) {
    let trace = matrix[0,0] + matrix[1,1] + matrix[2,2]

    if trace > 0.0 {
      var root = Double.sqrt(trace + 1.0)
      self.w = root / 2.0
      root = 0.5 / root

      self.x = (matrix[2,1] - matrix[1,2]) * root
      self.y = (matrix[0,2] - matrix[2,0]) * root
      self.z = (matrix[1,0] - matrix[0,1]) * root
    } else {
      var i = 0
      if (matrix[1,1] > matrix[0,0]) {
        i = 1
      }
      if (matrix[2,2] > matrix[i,i]) {
        i = 2
      }
      let j = (i + 1) % 3
      let k = (j + 1) % 3

      var root = Double.sqrt(matrix[i,i] - matrix[j,j] - matrix[k,k] + 1.0)
      var comp = [0.0, 0.0, 0.0]
      comp[i] = 0.5 * root
      root = 0.5 / root
      comp[j] = (matrix[j,i] + matrix[i,j]) * root
      comp[k] = (matrix[k,i] + matrix[i,k]) * root

      self.w = (matrix[k,j] - matrix[j,k]) * root
      self.x = comp[0]
      self.y = comp[1]
      self.z = comp[2]
    }
  }

  /// Initializes a unit quaternion representing the rotation from one vector to another.
  ///
  /// This initializer calculates a quaternion `q` such that `q * v = u`.
  ///
  /// - Parameters:
  ///   - v: A vector.
  ///   - u: The vector obtained by applying the computed rotation.
  public init(from v: Vector3, to u: Vector3, up: Vector3 = .unitY) {
//    let d = v.dot(u)
//    if abs(d - (-1.0)) < 0.000001 {
//      // `v` and `u` point in the opposite direction, so it is a 180° turn around the up-axis.
//      self = Quaternion(w: Double.pi, x: up.x, y: up.y, z: up.z)
//    } else if abs(d - 1.0) < 0.000001 {
//      // `v` and `u` point in the same direction.
//      self = .identity
//    }
//
//    let angle = Angle(radians: Double.acos(d))
//    let axis = v.cross(u).normalized
//    self.init(axis: axis, angle: angle)

    let cos2Theta = v.dot(u)
    let vu = v.cross(u)
    let w = 1.0 + cos2Theta
    let l = Double.sqrt(w * w + vu.x * vu.x + vu.y * vu.y + vu.z * vu.z)

    self.w = w / l
    self.x = vu.x / l
    self.y = vu.y / l
    self.z = vu.z / l
  }

  /// The quaternion's w-component.
  public var w: Double

  /// The quaternion's x-component.
  public var x: Double

  /// The quaternion's y-component.
  public var y: Double

  /// The quaternion's z-component.
  public var z: Double

  /// The quaternion's magnitude (a.k.a. length or norm).
  public var magnitude: Double {
    return Double.sqrt(w * w + x * x + y * y + z * z)
  }

  /// The quaternion's squared magnitude.
  ///
  /// Use this property rather than `magnitude` if you do not need the exact magnitude of the
  /// quaternion, but just want know if it is `0` or if it is longer than another quaternion's.
  public var squaredMagnitude: Double {
    return w * w + x * x + y * y + z * z
  }

  /// This quaternion, normalized.
  public var normalized: Quaternion {
    let l = magnitude
    return l != 0.0
      ? self / l
      : self
  }

  /// This quaternion, inverted.
  public var inverted: Quaternion {
    let lenSq = w * w + x * x + y * y + z * z
    if lenSq != 0.0 {
      let inv = 1.0 / lenSq
      return Quaternion(w: w * inv, x: -x * inv, y: -y * inv, z: -z * inv)
    } else {
      return self
    }
  }

  /// Computes the dot (a.k.a. scalar) product of this quaternion with another.
  ///
  /// - Parameter other: The quaternion with which calculate the dot product.
  public func dot(_ other: Quaternion) -> Double {
    return w * other.w + x * other.x + y * other.y + z * other.z
  }

  /// The axis-angle representation of the rotation represented by this quaternion.
  public var axisAngle: (axis: Vector3, angle: Angle) {
    get {
      let angle = Angle(radians: 2.0 * Double.acos(w))

      let d = Double.sqrt(1.0 - w * w)
      if d > 0.0 {
        return (axis: Vector3(x: x / d, y: y / d, z: z / d), angle: angle)
      } else {
        // The angle is null, so any normalized axis will do.
        return (axis: Vector3.unitX, angle: angle)
      }
    }

    set {
      self = Quaternion(axis: newValue.axis, angle: newValue.angle)
    }
  }

  /// The rotation represented by this quaternion, as a transformation matrix.
  public var transform: Matrix4 {
    get {
      let x2 = x + x
      let y2 = y + y
      let z2 = z + z

      let lengthSquared = w * w + x * x + y * y + z * z
      let wx = w * x2 / lengthSquared
      let wy = w * y2 / lengthSquared
      let wz = w * z2 / lengthSquared
      let xx = x * x2 / lengthSquared
      let xy = x * y2 / lengthSquared
      let xz = x * z2 / lengthSquared
      let yy = y * y2 / lengthSquared
      let yz = y * z2 / lengthSquared
      let zz = z * z2 / lengthSquared

      var result = Matrix4.zero

      result[0,0] = 1.0 - (yy + zz)
      result[1,0] = xy + wz
      result[2,0] = xz - wy
      result[0,1] = xy - wz
      result[1,1] = 1.0 - (xx + zz)
      result[2,1] = yz + wx
      result[0,2] = xz + wy
      result[1,2] = yz - wx
      result[2,2] = 1.0 - (xx + yy)
      result[3,3] = 1.0

      return result
    }

    set {
      self = Quaternion(matrix: newValue)
    }
  }

  /// The local yaw element of this quaternion.
  public var yaw: Angle {
    let sycp = 2.0 * (w * z + x * y)
    let cycp = 1.0 - 2.0 * (y * y + z * z)
    return Angle(radians: Double.atan2(y: sycp, x: cycp))
  }

  /// The local pitch element of this quaternion.
  public var pitch: Angle {
    let sp = 2.0 * (w * y + x * z)
    let rd = abs(sp) >= 1
      ? Double(signOf: sp, magnitudeOf: Double.pi / 2)
      : Double.asin(sp)
    return Angle(radians: rd)
  }

  /// The local roll element of this quaternion.
  public var roll: Angle {
    let srcp = 2.0 * (w * x + y * z)
    let crcp = 1.0 - 2.0 * (x * x + y * y)
    return Angle(radians: Double.atan2(y: srcp, x: crcp))
  }

  /// Computes the normalized linear interpolation (nlerp) between this quaternion and another.
  ///
  /// - Parameters:
  ///   - other: The other quaternion between which compute the interpolation.
  ///   - distance: The distance from this quaternion to the other, in the range `[0, 1]`.
  public func nlrep(with other: Quaternion, distance: Double) -> Quaternion {
    return (self + (other - self) * distance).normalized
  }

  /// Computes the spherical linear interpolation (slerp) between this quaternion and another.
  ///
  /// - Parameters:
  ///   - other: The other quaternion between which compute the interpolation.
  ///   - distance: The distance from this quaternion to the other, in the range `[0, 1]`.
  public func slerp(with other: Quaternion, distance: Double) -> Quaternion {
    let cosHalfTheta = dot(other)
    if cosHalfTheta < 0.95 {
      // Standard case (slerp)
      let sinHalfTheta = Double.sqrt(1.0 - cosHalfTheta * cosHalfTheta)
      let angle = Double.atan2(y: sinHalfTheta, x: cosHalfTheta)
      let coef0 = Double.sin((1.0 - distance) * angle) / sinHalfTheta
      let coef2 = Double.sin(distance * angle) / sinHalfTheta
      return self * coef0 + other * coef2
    } else {
      // There are two situations here:
      // - `self` and `other` are very close, so a linear interpolation is safe.
      // - `self` and `other` are almost inverse of each other, thus there is an infinite number of
      //   possible interpolations. Since we don't have a strategy to solve this situation, we may
      //   as well get away with a linear interpolation.
      return nlrep(with: other, distance: distance)
    }
  }

  /// Returns the component-wise addition of two quaternions.
  ///
  /// - Parameters:
  ///   - lhs: The first quaternions to add.
  ///   - rhs: The second quaternion to add.
  public static func + (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    return Quaternion(w: lhs.w + rhs.w, x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }

  /// Computes the component-wise addition of two quaternions and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The first quaternions to add.
  ///   - rhs: The second quaternions to add.
  public static func += (lhs: inout Quaternion, rhs: Quaternion) {
    lhs.w += rhs.w
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
  }

  /// Returns the component-wise subtraction of two quaternions.
  ///
  /// - Parameters:
  ///   - lhs: A quaternions.
  ///   - rhs: The quaternions to subtract from `lhs`.
  public static func - (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    return Quaternion(w: lhs.w - rhs.w, x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
  }

  /// Computes the component-wise subtraction of two quaternions and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: A quaternions.
  ///   - rhs: The quaternions to subtract from `lhs`.
  public static func -= (lhs: inout Quaternion, rhs: Quaternion) {
    lhs.w -= rhs.w
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
  }

  /// Returns the multiplication of two quaternions.
  ///
  /// If `q` and `r` are unit quaternions, then their multiplication is the composition (a.k.a.
  /// concatenation) of the rotation they represent.
  ///
  /// This operation is not commutative. In other words, there are pairs of quaternions for which
  /// `q * r != r * q`. Consequently, you should be careful of the operands' order.
  ///
  /// - Parameters:
  ///   - q: The first quaternion.
  ///   - r: The quaternion to compose with `q`.
  public static func * (q: Quaternion, r: Quaternion) -> Quaternion {
    return Quaternion(
      w: q.w * r.w - q.x * r.x - q.y * r.y - q.z * r.z,
      x: q.w * r.x + q.x * r.w + q.y * r.z - q.z * r.y,
      y: q.w * r.y + q.y * r.w + q.x * r.z - q.z * r.x,
      z: q.w * r.z + q.z * r.w + q.x * r.y - q.y * r.x)
  }

  /// Returns the rotation of a vector by a quaternion.
  ///
  /// - Parameters:
  ///   - q: A unit quaternion representing the rotation.
  ///   - v: The vector to rotate.
  public static func * (q: Quaternion, v: Vector3) -> Vector3 {
    // nVidia SDK implementation
    let qvec = Vector3(x: q.x, y: q.y, z: q.z)
    var uv = qvec.cross(v)
    var uuv = qvec.cross(uv)
    uv = uv * (2.0 * q.w)
    uuv = uuv * 2.0
    return v + uv + uuv
  }

  /// Returns the multiplication of a quaternion by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The quaternion to multiply.
  ///   - rhs: A scalar value.
  public static func * (lhs: Quaternion, rhs: Double) -> Quaternion {
    return Quaternion(w: lhs.w * rhs, x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
  }

  /// Computes the multiplication of a quaternion by a scalar and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The quaternion to multiply.
  ///   - rhs: A scalar value.
  public static func *= (lhs: inout Quaternion, rhs: Double) {
    lhs.w *= rhs
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
  }

  /// Returns the division of a quaternion by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The quaternion to divide.
  ///   - rhs: A scalar value.
  public static func / (lhs: Quaternion, rhs: Double) -> Quaternion {
    return Quaternion(w: lhs.w / rhs, x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
  }

  /// Computes the division of a quaternion by a scalar and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The quaternion to divide.
  ///   - rhs: A scalar value.
  public static func /= (lhs: inout Quaternion, rhs: Double) {
    lhs.w /= rhs
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
  }

  /// The quaternion whose 4 components are zero.
  public static var zero: Quaternion { Quaternion(w: 0.0, x: 0.0, y: 0.0, z: 0.0) }

  /// The unit quaternion representing the identity rotation.
  public static var identity: Quaternion { Quaternion(w: 1.0, x: 0.0, y: 0.0, z: 0.0) }

}

extension Quaternion: CustomStringConvertible {

  public var description: String {
    // Roll (x-axis rotation)
    let sinRByCosP = 2.0 * (w * x + y * z)
    let cosRByCosP = 1.0 - 2.0 * (x * x + y * y)
    let roll = Angle(radians: Double.atan2(y: sinRByCosP, x: cosRByCosP))

    // Pitch (y-axis rotation)
    let sinP = 2.0 * (w * y - z * x)
    let pitch = abs(sinP) >= 1.0
      ? Angle(radians: Double(signOf: sinP, magnitudeOf: Double.pi / 2.0))
      : Angle(radians: Double.asin(sinP))

    // Yaw (z-axis rotation)
    let sinYByCosP = 2.0 * (w * z + x * y)
    let cosYByCosP = 1.0 - 2.0 * (y * y + z * z)
    let yaw = Angle(radians: Double.atan2(y: sinYByCosP, x: cosYByCosP))

    return "(x: \(roll.degrees), y: \(pitch.degrees), z: \(yaw.degrees))"
  }

}
