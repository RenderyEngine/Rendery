/// A view that responds to the input events dispatched to its subview.
public final class InputResponderView {

  /// Initializes an input responder view for the specified subview.
  ///
  /// - Parameter subview: The subview for which respond to events.
  public init(_ subview: View) {
    self.subview = subview
    self.subview.container = self
  }

  public weak var container: View?

  /// The subview for which this view responds to input events.
  public let subview: View

  /// The callback that responds to key press events.
  public var onKeyPress: ((KeyEvent) -> Void)?

  public func setting(
    onKeyPress: @escaping (_ event: KeyEvent) -> Void
  ) -> InputResponderView {
    self.onKeyPress = onKeyPress
    return self
  }

  /// The callback that responds to key release events.
  public var onKeyRelease: ((KeyEvent) -> Void)?

  public func setting(
    onKeyRelease: @escaping (_ event: KeyEvent) -> Void
  ) -> InputResponderView {
    self.onKeyRelease = onKeyPress
    return self
  }

  /// The callback that responds to mouse press events.
  public var onMousePress: ((MouseEvent) -> Void)?

  public func setting(
    onMousePress: @escaping (_ event: MouseEvent) -> Void
  ) -> InputResponderView {
    self.onMousePress = onMousePress
    return self
  }

  /// The callback that responds to mouse release events.
  public var onMouseRelease: ((MouseEvent) -> Void)?

  public func setting(
    onMouseRelease: @escaping (_ event: MouseEvent) -> Void
  ) -> InputResponderView {
    self.onMouseRelease = onMouseRelease
    return self
  }

}

extension InputResponderView: View {

  public var dimensions: Vector2 { subview.dimensions }

  public func view(at point: Vector2) -> View? {
    return subview.view(at: point)
  }

  public func draw<Context>(in context: inout Context) where Context: ViewDrawingContext {
    subview.draw(in: &context)
  }

}

extension InputResponderView: InputResponder {

  public var nextResponder: InputResponder? {
    var view = self as View
    while let superview = view.container {
      if let responder = superview as? InputResponder {
        return responder
      }
      view = superview
    }

    return nil
  }

  public func respondToKeyPress(with event: KeyEvent) {
    if let handler = onKeyPress {
      handler(event)
    } else {
      nextResponder?.respondToKeyPress(with: event)
    }
  }

  public func respondToKeyRelease(with event: KeyEvent) {
    if let handler = onKeyRelease {
      handler(event)
    } else {
      nextResponder?.respondToKeyRelease(with: event)
    }
  }

  public func respondToMousePress(with event: MouseEvent) {
    if let handler = onMousePress {
      handler(event)
    } else {
      nextResponder?.respondToMousePress(with: event)
    }
  }

  public func respondToMouseRelease(with event: MouseEvent) {
    if let handler = onMouseRelease {
      handler(event)
    } else {
      nextResponder?.respondToMouseRelease(with: event)
    }
  }

}
