/// A view element.
///
/// Views represent a flat, rectangular area that displays some kind of 2D content. They are meant
/// to be combined to create a so-called "view tree", which typically represents a user interface,
/// such as a heads-up display.
public protocol View: AnyObject {

  /// The view's dimensions.
  ///
  /// Views are drawn within the bounds of an invisible rectangle, whose top-left corner
  /// corresponds to the origin of the view's coordinate system. This property specifies the
  /// dimensions of that rectangle.
  ///
  /// A view has the final say to compute its own dimensions, regardless of its container's. This
  /// means that a view contained within a smaller container may choose to draw itself with onto
  /// a larger area. However, containmnent check will fail for any point in the overflowing area.
  /// Furthermore, the container is free to clip overflowing content.
  var dimensions: Vector2 { get }

  /// The view container in which this view lies, if any.
  ///
  /// You should not set this property manually. View containers are responsible for (re)assigning
  /// it when the view is added to them.
  var container: View? { get set }

  /// Returns the deepest view that contains the specified point.
  ///
  /// A point is contained if it lies within the invisible rectangle whose top-left corner is at
  /// `(0,0)` and whose dimensions are equal to the view's `dimensions`
  ///
  /// - Parameter point: A point in the view's coordinate system.
  func view(at point: Vector2) -> View?

  /// Sets a key press event handler on this view.
  ///
  /// - Parameter onKeyPress: A key press event handler.
  func setting(onKeyPress: @escaping (_ event: KeyEvent) -> Void) -> InputResponderView

  /// Sets a key release event handler on this view.
  ///
  /// - Parameter onKeyRelease: A key press event handler.
  func setting(onKeyRelease: @escaping (_ event: KeyEvent) -> Void) -> InputResponderView

  /// Sets a mouse press event handler on this view.
  ///
  /// - Parameter onMousePress: A mouse press event handler.
  func setting(onMousePress: @escaping (_ event: MouseEvent) -> Void) -> InputResponderView

  /// Sets a mouse release event handler on this view.
  ///
  /// - Parameter onMouseRelease: A mouse release event handler.
  func setting(onMouseRelease: @escaping (_ event: MouseEvent) -> Void) -> InputResponderView

  /// Draws this view in the specified drawing context.
  ///
  /// This method executes the commands actually draw the view's content onto a rendering surface.
  /// The `context` parameter encapsulate the state of a renderer and provides an API to draw
  /// primitive graphical elements (e.g., a colored rectangle).
  ///
  /// - Parameter context: The context use for drawing.
  func draw<Context>(in context: inout Context) where Context: ViewDrawingContext

}

extension View {

  public func view(at point: Vector2) -> View? {
    guard (point.x >= 0.0) && (point.x <= dimensions.x)
      else { return nil }
    guard (point.y >= 0.0) && (point.y <= dimensions.y)
      else { return nil }
    return self
  }

  public func setting(
    onKeyPress: @escaping (_ event: KeyEvent) -> Void
  ) -> InputResponderView {
    InputResponderView(self).setting(onKeyPress: onKeyPress)
  }

  public func setting(
    onKeyRelease: @escaping (_ event: KeyEvent) -> Void
  ) -> InputResponderView {
    InputResponderView(self).setting(onKeyRelease: onKeyRelease)
  }

  public func setting(
    onMousePress: @escaping (_ event: MouseEvent) -> Void
  ) -> InputResponderView {
    InputResponderView(self).setting(onMousePress: onMousePress)
  }

  public func setting(
    onMouseRelease: @escaping (_ event: MouseEvent) -> Void
  ) -> InputResponderView {
    InputResponderView(self).setting(onMouseRelease: onMouseRelease)
  }

  /// Creates a frame around this view.
  ///
  /// - Parameters:
  ///   - width: The frame's width. If this parameter is assigned to `nil`, the frame will be
  ///     initialized with this view's width.
  ///   - height: The frame's height. If this parameter is assigned to `nil`, the frame will be
  ///     initialized with this view's height.
  ///   - alignment: The view's alignment in the frame.
  public func framed(
    width: Double? = nil,
    height: Double? = nil,
    alignment: FrameView.Alignment = .center
  ) -> FrameView {
    let view = FrameView(around: self)

    if let x = width {
      view.dimensions.x = x
    }
    if let y = height {
      view.dimensions.y = y
    }
    view.alignment = alignment

    return view
  }

  /// Creates a frame around this view, adding padding around this view's content.
  public func framed(padding: Double) -> FrameView {
    let dim = dimensions
    return framed(
      width: dim.x + padding * 2.0,
      height: dim.y + padding * 2.0,
      alignment: .center)
  }

}
