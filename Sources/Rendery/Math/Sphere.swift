/// A sphere.
public struct Sphere {

  /// Initializes a sphere with its origin and radius.
  ///
  /// - Parameters:
  ///   - origin: The sphere's origin.
  ///   - radius: The sphere's radius.
  public init(origin: Vector3, radius: Double) {
    self.origin = origin
    self.radius = radius
  }

  /// The sphere's origin.
  public var origin: Vector3

  /// The sphere's radius.
  public var radius: Double

}

extension Sphere: CustomStringConvertible {

  public var description: String {
    return "Sphere(origin: \(origin), radius: \(radius))"
  }

}
