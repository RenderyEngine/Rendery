public struct Overlay<Subview> where Subview: View {

  public init(_ elements: [Element]) {
    _elements = elements
  }

  private var _elements: [Element]

  public func elements(_ elements: [Element]) -> Overlay {
    var newOverlay = self
    newOverlay._elements = elements
    return newOverlay
  }

  public struct Element {

    public init(_ subview: Subview, offset: Vector2 = .zero) {
      self.subview = subview
      self._offset = offset
    }

    public let subview: Subview

    private var _offset: Vector2

    public func offset(_ offset: Vector2) -> Element {
      var newElement = self
      newElement._offset = offset
      return newElement
    }

  }

}

extension Overlay: View {

  public func render(into renderer: inout ViewRenderer) {
    let penPosition = renderer.penPosition
    for element in _elements {
      element.render(into: &renderer)
    }
    renderer.penPosition = penPosition
  }

}

extension Overlay.Element: View {

  public func render(into renderer: inout ViewRenderer) {
    renderer.penPosition = _offset
    subview.render(into: &renderer)
  }

}
