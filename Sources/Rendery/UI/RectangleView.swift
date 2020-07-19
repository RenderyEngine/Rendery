public final class RectangleView {

  public init(dimensions: Vector2, color: Color) {
    self.dimensions = dimensions
    self.color = color
  }

  public var dimensions: Vector2

  public weak var container: View?

  /// The rectangle's color.
  public var color: Color

}

extension RectangleView: View {

  public func draw<Context>(in context: inout Context) where Context : ViewDrawingContext {
    context.fill(
      rectangle: Rectangle(origin: .zero, dimensions: dimensions), color: color)
  }

}
