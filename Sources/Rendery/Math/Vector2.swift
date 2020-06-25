import Numerics

/// A structure that represents a 2-dimensional vector.
///
/// 2D vectors are represented as distances along three orthogonal axes (x and y). They are used
/// for a variety of purposes (e.g., to describe positions, directions, scale factors, etc.). Thus,
/// the meaning of each component should be interpreted based on the context.
public struct Vector2: Hashable {

  /// Initializes a vector with components specified as floating-point values.
  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  /// The vector's x-component.
  public var x: Double

  /// The vector's y-component.
  public var y: Double

  /// The vector's magnitude (a.k.a. length or norm).
  public var magnitude: Double {
    return Double.hypot(x, y)
  }

  /// The vector's squared magnitude.
  ///
  /// Use this property rather than `magnitude` if you do not need the exact magnitude of the
  /// vector, but just want know if it is `0` or if it is longer than another vector's.
  public var squaredMagnitude: Double {
    return x * x + y * y
  }

  /// This vector, normalized.
  public var normalized: Vector2 {
    let l = magnitude
    return l != 0.0
      ? self / l
      : self
  }

  /// Computes the dot (a.k.a. scalar) product of this vector with another.
  ///
  /// - Parameter other: The vector with which calculate the dot product.
  public func dot(_ other: Vector2) -> Double {
    return x * other.x + y * other.y
  }

  /// Computes the Euclidean distance between this vector and another.
  ///
  /// - Parameter other: The vector with which calculate the distance.
  public func distance(to other: Vector2) -> Double {
    return (other - self).magnitude
  }

  /// Computes the squared Euclidean distance between this vector and another.
  ///
  /// - Parameter other: The vector with which calculate the distance.
  public func squaredDistance(to other: Vector2) -> Double {
    return (other - self).squaredMagnitude
  }

  /// Computes the vector obtained after rotating this vector by the specified angle.
  ///
  /// - Parameter angle: An angle specifying the rotation to compute.
  public func rotated(by angle: Angle) -> Vector2 {
    let ca = Double.cos(angle.radians)
    let sa = Double.sin(angle.radians)
    return Vector2(
      x: x * ca - y * sa,
      y: x * sa + y * ca)
  }

  /// Returns the component-wise addition of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to add.
  ///   - rhs: The second vector to add.
  public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
    return Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  /// Computes the component-wise addition of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to add.
  ///   - rhs: The second vector to add.
  public static func += (lhs: inout Vector2, rhs: Vector2) {
    lhs.x += rhs.x
    lhs.y += rhs.y
  }

  /// Returns the component-wise subtraction of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: The vector to subtract from `lhs`.
  public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
    return Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  /// Computes the component-wise subtraction of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: A vector.
  ///   - rhs: The vector to subtract from `lhs`.
  public static func -= (lhs: inout Vector2, rhs: Vector2) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
  }

  /// Computes the additive opposite of a vector.
  ///
  /// - Parameter operand: The value for which compute the opposite.
  prefix public static func - (operand: Vector2) -> Vector2 {
    return Vector2(x: -operand.x, y: -operand.y)
  }

  /// Returns the component-wise multiplication of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to multiply.
  ///   - rhs: The second vector to multiply.
  public static func * (lhs: Vector2, rhs: Vector2) -> Vector2 {
    return Vector2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
  }

  /// Computes the component-wise multiplication of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The first vector to multiply.
  ///   - rhs: The second vector to multiply.
  public static func *= (lhs: inout Vector2, rhs: Vector2) {
    lhs.x *= rhs.x
    lhs.y *= rhs.y
  }

  /// Returns the multiplication of a vector by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The vector to multiply.
  ///   - rhs: A scalar value.
  public static func * (lhs: Vector2, rhs: Double) -> Vector2 {
    return Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
  }

  /// Computes the multiplication of a vector by a scalar and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The vector to multiply.
  ///   - rhs: A scalar value.
  public static func *= (lhs: inout Vector2, rhs: Double) {
    lhs.x *= rhs
    lhs.y *= rhs
  }

  /// Returns the component-wise division of two vectors.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: The vector by which divide `lhs`.
  public static func / (lhs: Vector2, rhs: Vector2) -> Vector2 {
    return Vector2(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
  }

  /// Computes the component-wise division of two vectors and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: The vector by which divide `lhs`.
  public static func / (lhs: inout Vector2, rhs: Vector2) {
    lhs.x /= rhs.x
    lhs.y /= rhs.y
  }

  /// Returns the division of a vector by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: A scalar value.
  public static func / (lhs: Vector2, rhs: Double) -> Vector2 {
    return Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
  }

  /// Computes the division of a vector by a scalar and stores the result in `lhs`.
  ///
  /// - Parameters:
  ///   - lhs: The vector to divide.
  ///   - rhs: A scalar value.
  public static func /= (lhs: inout Vector2, rhs: Double) {
    lhs.x /= rhs
    lhs.y /= rhs
  }

  /// The vector whose 2 components are zero.
  public static var zero: Vector2 { Vector2(x: 0.0, y: 0.0) }

  /// The vector whose 2 components are one.
  public static var unitScale: Vector2 { Vector2(x: 1.0, y: 1.0) }

  /// The vector whose x-component is one and y-component it zero.
  public static var unitX: Vector2 { Vector2(x: 1.0, y: 0.0) }

  /// The vector whose y-component is one and x-component is zero.
  public static var unitY: Vector2 { Vector2(x: 0.0, y: 1.0) }

}

extension Vector2: CustomStringConvertible {

  public var description: String {
    return "(\(x), \(y))"
  }

}
