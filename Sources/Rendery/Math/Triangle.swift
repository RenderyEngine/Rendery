/// A polygon defined by three vertices.
public struct Triangle: Hashable {

  /// Initializes a triangle with three vertices.
  ///
  /// - Parameters:
  ///   - a: The triangle's first vertex.
  ///   - b: The triangle's second vertex.
  ///   - c: The triangle's third vertex.
  public init(a: Vector3, b: Vector3, c: Vector3) {
    self.a = a
    self.b = b
    self.c = c
  }

  /// The triangle's first vertex.
  public var a: Vector3

  /// The triangle's second vertex.
  public var b: Vector3

  /// The triangle's thrid vertex.
  public var c: Vector3

}

extension Triangle: CustomStringConvertible {

  public var description: String {
    return "Triangle(a: \(a), b: \(b), c: \(c))"
  }

}
