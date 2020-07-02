public struct RectangleView {

  public init(dimensions: Vector2, fill: Color) {
    self.dimensions = dimensions
    self.fill = fill
  }

  public var dimensions: Vector2

  public func dimensions(_ value: Vector2) -> RectangleView {
    var newView = self
    newView.dimensions = value
    return newView
  }

  public var fill: Color

  public func fill(_ value: Color) -> RectangleView {
    var newView = self
    newView.fill = value
    return newView
  }

}

extension RectangleView: View {

  public func render(into renderer: inout ViewRenderer) {
    renderer.draw(rectangleOfSize: dimensions, color: fill)
  }

}
