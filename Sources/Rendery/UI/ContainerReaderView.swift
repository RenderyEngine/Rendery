public final class ContainerReaderView {

  public init(_ content: @escaping (_ container: View?) -> View) {
    self.content = content
  }

  public weak var container: View?

  public var content: (View?) -> View

}

extension ContainerReaderView: View {

  public var dimensions: Vector2 {
    return content(container).dimensions
  }

  public func draw<Context>(in context: inout Context) where Context: ViewDrawingContext {
    content(container).draw(in: &context)
  }

}
