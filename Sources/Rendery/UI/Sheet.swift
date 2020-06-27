public struct Sheet<Subview>: View where Subview: View {

  public init(dimensions: Vector2, containing subview: Subview) {
    self._dimensions = dimensions
    self._subview = subview
  }

  private var _dimensions: Vector2

  private var _subview: Subview

  public func render(into renderer: inout ViewRenderer) {
//    renderer.draw(mesh: ViewRenderer.rectangle)
    renderer.draw(rectangle: Rectangle(origin: .zero, dimensions: _dimensions), color: .purple)

    _subview.render(into: &renderer)
  }

}
