import Numerics

/// A structure that represents a 3-dimensional vector.
///
/// 3D vectors are represented as distances along three orthogonal axes (x, y and z). They are used
/// for a variety of purposes (e.g., to describe positions, directions, scale factors, etc.). Thus,
/// the meaning of each component should be interpreted based on the context.
public struct Vector3: Hashable {

  /// Initializes a vector with components specified as floating-point values.
  public init(x: Double, y: Double, z: Double) {
    self.x = x
    self.y = y
    self.z = z
  }

  /// The vector's x-component.
  public var x: Double

  /// The vector's y-component.
  public var y: Double

  /// The vector's z-component.
  public var z: Double

  /// The vector's magnitude (a.k.a. length or norm).
  public var magnitude: Double {
    return Double.sqrt(x * x + y * y + z * z)
  }

  /// The vector's squared magnitude.
  ///
  /// Use this property rather than `magnitude` if you do not need the exact magnitude of the
  /// vector, but just want know if it is `0` or if it is longer than another vector's.
  public var squaredMagnitude: Double {
    return x * x + y * y + z * z
  }

  /// This vector, normalized.
  public var normalized: Vector3 {
    let l = magnitude
    return l != 0.0
      ? self / l
      : self
  }

  /// Computes the dot (a.k.a. scalar) product of this vector with another.
  ///
  /// - Parameter other: The vector with which calculate the dot product.
  public func dot(_ other: Vector3) -> Double {
    return x * other.x + y * other.y + z * other.z
  }

  /// Computes the cross (a.k.a. vector) product of this vector with another.
  ///
  /// The cross product of two vectors `v`and `u` is a vector that is perpendicular to both `v` and
  /// `u` and thus normal to the plane containing them.
  ///
  /// - Parameter other: The vector with which to calculate the cross product.
  public func cross(_ other: Vector3) -> Vector3 {
    return Vector3(
      x: y * other.z - z * other.y,
      y: z * other.x - x * other.z,
      z: x * other.y - y * other.x)
  }

  /// Computes the Euclidean distance between this vector and another.
  ///
  /// - Parameter other: The vector with which calculate the distance.
  public func distance(to other: Vector3) -> Double {
    return (other - self).magnitude
  }

  /// Computes the squared Euclidean distance between this vector and another.
  ///
  /// - Parameter other: The vector with which calculate the distance.
  public func squaredDistance(to other: Vector3) -> Double {
    return (other - self).squaredMagnitude
  }

  /// Computes the Euclidean distance between this vector and the closest face of an axis-aligned
  /// box.
  ///
  /// - Parameter box: The box with which calculate the distance.
  public func distance(to box: AxisAlignedBox) -> Double {
    return Double.sqrt(squaredDistance(to: box))
  }

  /// Computes the squared Euclidean distance between this vector and the closest face of an
  /// axis-aligned box.
  ///
  /// - Parameter box: The box with which calculate the distance.
  public func squaredDistance(to box: AxisAlignedBox) -> Double {
    func check(p: Double, bmin: Double, bmax: Double) -> Double {
      if p < bmin {
        let v = bmin - p
        return v * v
      } else if p > bmax {
        let v = p - bmax
        return v * v
      } else {
        return 0.0
      }
    }

    var d = check(p: x, bmin: box.minX, bmax: box.maxX)
    d = d + check(p: y, bmin: box.minY, bmax: box.maxY)
    d = d + check(p: z, bmin: box.minZ, bmax: box.maxZ)
    return d
  }

  /// Returns the component-wise addition of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to add.
  ///   - rhs: The second vector to add.
  public static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }

  /// Computes the component-wise addition of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to add.
  ///   - rhs: The second vector to add.
  public static func += (lhs: inout Vector3, rhs: Vector3) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
  }

  /// Returns the component-wise subtraction of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: The vector to subtract from `lhs`.
  public static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
  }

  /// Computes the component-wise subtraction of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: The vector to subtract from `lhs`.
  public static func -= (lhs: inout Vector3, rhs: Vector3) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
  }

  /// Computes the additive opposite of a vector.
  ///
  /// - Parameter operand: The value for which compute the opposite.
  prefix public static func - (operand: Vector3) -> Vector3 {
    return Vector3(x: -operand.x, y: -operand.y, z: -operand.z)
  }

  /// Returns the component-wise multiplication of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to multiply.
  ///   - rhs: The second vector to multiply.
  public static func * (lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
  }

  /// Computes the component-wise multiplication of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to multiply.
  ///   - rhs: The second vector to multiply.
  public static func *= (lhs: inout Vector3, rhs: Vector3) {
    lhs.x *= rhs.x
    lhs.y *= rhs.y
    lhs.z *= rhs.z
  }

  /// Returns the multiplication of a vector by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The vector to multiply.
  ///   - rhs: A scalar value.
  public static func * (lhs: Vector3, rhs: Double) -> Vector3 {
    return Vector3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
  }

  /// Computes the multiplication of a vector by a scalar and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The vector to multiply.
  ///   - rhs: A scalar value.
  public static func *= (lhs: inout Vector3, rhs: Double) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
  }

  /// Returns the component-wise division of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: The vector by which divide `lhs`.
  public static func / (lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
  }

  /// Computes the component-wise division of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: The vector by which divide `lhs`.
  public static func /= (lhs: inout Vector3, rhs: Vector3) {
    lhs.x /= rhs.x
    lhs.y /= rhs.y
    lhs.z /= rhs.z
  }

  /// Returns the division of a vector by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: A scalar value.
  public static func / (lhs: Vector3, rhs: Double) -> Vector3 {
    return Vector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
  }

  /// Computes the division of a vector by a scalar and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: A scalar value.
  public static func /= (lhs: inout Vector3, rhs: Double) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
  }

  /// The vector whose 3 components are zero.
  public static let zero = Vector3(x: 0.0, y: 0.0, z: 0.0)

  /// The vector whose 3 components are one.
  public static let unitScale = Vector3(x: 1.0, y: 1.0, z: 1.0)

  /// The vector whose x-component is one and other components are zero.
  public static let unitX = Vector3(x: 1.0, y: 0.0, z: 0.0)

  /// The vector whose y-component is one and other components are zero.
  public static let unitY = Vector3(x: 0.0, y: 1.0, z: 0.0)

  /// The vector whose z-component is one and other components are zero.
  public static let unitZ = Vector3(x: 0.0, y: 0.0, z: 1.0)

}

extension Vector3: CustomStringConvertible {

  public var description: String {
    return "Vector3(x: \(x), y: \(y), z: \(z))"
  }

}
