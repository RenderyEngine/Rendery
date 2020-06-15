/// A structure that represents an angle.
///
/// This structure is intended to be used as a wrapper for angle values, rather than expressing it
/// as a raw double value. The advantage is that this dispels any possible confusion between values
/// given degrees or in radians.
public struct Angle {

  /// Initialize an angle with its value in radians.
  ///
  /// - Parameter radians: The angle's value, in radians.
  public init(radians: Double) {
    self.radians = radians
  }

  /// Initialize an angle with its value in degrees.
  ///
  /// - Parameter degrees: The angle's value, in degrees.
  public init(degrees: Double) {
    self.radians = degrees * Double.pi / 180
  }

  /// The angle's value, in radians.
  public var radians: Double

  /// The angle's value, in degrees.
  public var degrees: Double {
    get { radians * 180 / Double.pi }
    set { radians = newValue * Double.pi / 180 }
  }

  /// Returns this angle wrapped within the interval `[0, 2 * pi[`.
  public var wrapped: Angle {
    var r = radians
    if r < 0 {
      while r < 0 {
        r = r + 2 * Double.pi
      }
    } else {
      while r >= 2 * Double.pi {
        r = r - 2 * Double.pi
      }
    }
    return Angle(radians: r)
  }

  /// A convenience method to initialize an angle from its value in radians.
  ///
  /// - Parameter value: The angle's value, in radians.
  public static func rad(_ value: Double) -> Angle { Angle(radians: value) }

  /// A convenience method to initialize an angle from its value in degree.
  ///
  /// - Parameter value: The angle's value, in degrees.
  public static func deg(_ value: Double) -> Angle { Angle(degrees: value) }

}

extension Angle: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrapped.radians)
  }

  public static func == (lhs: Angle, rhs: Angle) -> Bool {
    return lhs.wrapped.radians == rhs.wrapped.radians
  }

}

extension Angle: Comparable {

  public static func < (lhs: Angle, rhs: Angle) -> Bool {
    return lhs.wrapped.radians < rhs.wrapped.radians
  }

}

extension Angle: AdditiveArithmetic {

  public static func + (lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians + rhs.radians)
  }

  public static func += (lhs: inout Angle, rhs: Angle) {
    lhs.radians += rhs.radians
  }

  public static func - (lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians - rhs.radians)
  }

  public static func -= (lhs: inout Angle, rhs: Angle) {
    lhs.radians -= rhs.radians
  }

  /// Returns the multiplication of an angle by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The angle to multiply.
  ///   - rhs: The scalar to multiply.
  public static func * (lhs: Angle, rhs: Double) -> Angle {
    return Angle(radians: lhs.radians * rhs)
  }

  /// Returns the division of an angle by a scalar.
  ///
  /// - Parameters:
  ///   - lhs: The angle to divide.
  ///   - rhs: The scalar by which `angle` should be divided.
  public static func / (lhs: Angle, rhs: Double) -> Angle {
    return Angle(radians: lhs.radians / rhs)
  }

  public static var zero: Angle { Angle(radians: 0.0) }

}
