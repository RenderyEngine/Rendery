public struct Sheet<Subview>: View where Subview: View {

  public init(dimensions: Vector2, containing subview: Subview) {
    self._dimensions = dimensions
    self._subview = subview
  }

  private var _dimensions: Vector2

  private var _subview: Subview

  private var _backgroundColor: Color = Color(red: 0, green: 0, blue: 0, alpha: 127)

  public func backgroundColor(_ color: Color) -> Sheet {
    var newSheet = self
    newSheet._backgroundColor = color
    return newSheet
  }

  public func render(into renderer: inout ViewRenderer) {
    renderer.draw(
      rectangle: Rectangle(origin: .zero, dimensions: _dimensions),
      color: _backgroundColor)

    _subview.render(into: &renderer)
  }

}
