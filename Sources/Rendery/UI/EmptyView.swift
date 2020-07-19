/// An empty view, that can be used to create spacers.
public final class EmptyView: View {

  /// Initializes an empty view.
  public init() {
  }

  public var dimensions: Vector2 { .zero }

  public weak var container: View?

  public func draw<Context>(in context: inout Context) where Context : ViewDrawingContext {
  }

}
