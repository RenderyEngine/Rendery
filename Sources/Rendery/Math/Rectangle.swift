/// A structure that contains the location and dimensions of a rectangle.
public struct Rectangle: Hashable {

  /// Initializes a rectangle with its origin and dimensions.
  ///
  /// - Parameters:
  ///   - origin: The rectangle's origin.
  ///   - dimensions: The rectangle's dimensions.
  public init(origin: Vector2, dimensions: Vector2) {
    self.origin = origin
    self.dimensions = dimensions
  }

  /// Initializes a rectanlge with its origin and dimensions, specified as individual values.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the rectangle's origin.
  ///   - y: The y-coordinate of the rectangle's origin.
  ///   - width: The rectangle's width.
  ///   - height: The rectangle's height.
  public init(x: Double, y: Double, width: Double, height: Double) {
    self.origin = Vector2(x: x, y: y)
    self.dimensions = Vector2(x: width, y: height)
  }

  /// Initializes a rectangle centered at the specified coordinate.
  ///
  /// - Parameters:
  ///   - center: A point designating the rectangle's center.
  ///   - dimensions: The rectangle's dimensions.
  public init(centeredAt center: Vector2, dimensions: Vector2) {
    self.origin = Vector2(
      x: center.x - dimensions.x / 2.0,
      y: center.y - dimensions.y / 2.0)
    self.dimensions = dimensions
  }

  /// The rectangle's origin (e.g., its left-bottom corner).
  public var origin: Vector2

  /// The rectangle's smallest x-coordinate.
  public var minX: Double { (dimensions.x > 0.0) ? origin.x : (origin.x + dimensions.x) }

  /// The rectangle's smallest y-coordinate.
  public var minY: Double { (dimensions.y > 0.0) ? origin.y : (origin.y + dimensions.y) }

  /// The rectangle's greatest x-coordinate.
  public var maxX: Double { (dimensions.x > 0.0) ? (origin.x + dimensions.x) : origin.x }

  /// The rectangle's greatest y-coordinate.
  public var maxY: Double { (dimensions.y > 0.0) ? (origin.y + dimensions.y) : origin.y }

  /// The rectangle's dimensions.
  public var dimensions: Vector2

  /// The rectangle's width.
  public var width: Double { abs(dimensions.x) }

  /// The rectangle's height.
  public var height: Double { abs(dimensions.y) }

  /// Returns the rectangle whose coordinates are scaled by the given factors.
  ///
  /// All coordinates are scaled, meaning that the new rectangle will not have the same if the
  /// this rectangle's origin is not zero.
  ///
  ///     let r1 = Rectangle(
  ///       origin: Vector2(x: 0.2, y: 0.5),
  ///       dimensions: Vector2(x: 0.5, y: 0.5))
  ///     let r2 = r1.scaled(by: Vector2(x: 8.0, y: 6.0))
  ///     print(r2.minX, r2.minY, r2.maxX, r2.maxX)
  ///     // Prints Rectangle(origin: (1.6, 3.0), dimensions: (4.0, 3.0))
  ///
  /// - Parameter factors: The scaling factors represented as a vector whose each component scales
  ///   the rectangle's coordinates along the corresponding aixs.
  public func scaled(by factors: Vector2) -> Rectangle {
    return Rectangle(origin: origin * factors, dimensions: dimensions * factors)
  }

  /// Returns the rectangle whose coordinates are scaled by the given factors.
  ///
  /// All coordinates are scaled, meaning that the new rectangle will not have the same if the
  /// this rectangle's origin is not zero.
  ///
  ///     let r1 = Rectangle(
  ///       origin: Vector2(x: 0.2, y: 0.5),
  ///       dimensions: Vector2(x: 0.5, y: 0.5))
  ///     let r2 = r1.scaled(x: 8.0, y: 6.0)
  ///     print(r2.minX, r2.minY, r2.maxX, r2.maxX)
  ///     // Prints Rectangle(origin: (1.6, 3.0), dimensions: (4.0, 3.0))
  ///
  /// - Parameters:
  ///     - x: The factor that scales the rectangle's horizontal coordinates.
  ///     - y: The factor that scales the rectangle's vertical coordinates.
  public func scaled(x: Double, y: Double) -> Rectangle {
    return Rectangle(
      origin: Vector2(x: origin.x * x, y: origin.y * y),
      dimensions: Vector2(x: dimensions.x * x, y: dimensions.y * y))
  }

  /// Returns whether the rectangle contains the specified point.
  public func contains(_ point: Vector2) -> Bool {
    return ((minX ..< maxX) ~= point.x) && ((minY ..< maxY) ~= point.y)
  }

}

extension Rectangle: CustomStringConvertible {

  public var description: String {
    return "Rectangle(origin: \(origin), dimensions: \(dimensions))"
  }

}
