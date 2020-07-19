public final class ViewportRootView {

  internal init(viewport: Viewport) {
    self.viewport = viewport
  }

  public unowned let viewport: Viewport

  public var subview: View? {
    didSet {
      subview?.container = self
    }
  }

}

extension ViewportRootView: View {

  public var container: View? {
    get { nil }
    set { }
  }

  public var dimensions: Vector2 {
    var d = viewport.region.dimensions
    d.x *= Double(viewport.target.width)
    d.y *= Double(viewport.target.height)
    return d
  }

  public func view(at point: Vector2) -> View? {
    return subview?.view(at: point)
  }

  public func draw<Context>(in context: inout Context) where Context: ViewDrawingContext {
    subview?.draw(in: &context)
  }

}
