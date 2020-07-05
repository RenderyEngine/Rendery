/// A view container that positions its subviews wifth offsets along both axes.
public struct OverlayView<Subview> where Subview: View {

  public init(_ elements: [Element] = []) {
    self.elements = elements
  }

  public init<S>(_ elements: S) where S: Sequence, S.Element == (Subview, Vector2) {
    self.init(elements.map({ pair in Element(subview: pair.0, offset: pair.1) }))
  }

  public var elements: [Element]

  public func elements(_ value: [Element]) -> OverlayView {
    var newView = self
    newView.elements = value
    return newView
  }

  public func append(_ value: Element) -> OverlayView {
    var newView = self
    newView.elements.append(value)
    return newView
  }

  public func append(_ subview: Subview, offset: Vector2) -> OverlayView {
    var newView = self
    newView.elements.append(Element(subview: subview, offset: offset))
    return newView
  }

  public struct Element {

    public init(subview: Subview, offset: Vector2) {
      self.subview = subview
      self._offset = offset
    }

    public let subview: Subview

    fileprivate var _offset: Vector2

    public func offset(_ offset: Vector2) -> Element {
      var newView = self
      newView._offset = offset
      return newView
    }

  }

}

extension OverlayView where Subview == AnyView {

  public func append<V>(_ subview: V, offset: Vector2) -> OverlayView where V: View {
    var newView = self
    newView.elements.append(Element(subview: AnyView(subview), offset: offset))
    return newView
  }

}

extension OverlayView: View {

  public var dimensions: Vector2 {
    var max = Vector2.zero

    for element in elements {
      let dim = element.subview.dimensions
      if dim.x + element._offset.x > max.x {
        max.x = dim.x + element._offset.x
      }
      if dim.y + element._offset.y > max.y {
        max.x = dim.x + element._offset.y
      }
    }

    return max
  }

  public func render(into renderer: inout ViewRenderer) {
    let currentPenPosition = renderer.penPosition
    for element in elements {
      element.render(into: &renderer)
      renderer.penPosition = currentPenPosition
    }
  }

}

extension OverlayView.Element: View {

  public var dimensions: Vector2 { subview.dimensions }

  public func render(into renderer: inout ViewRenderer) {
    renderer.penPosition = renderer.penPosition + _offset
    subview.render(into: &renderer)
  }

}
