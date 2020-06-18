/// A type that implements the custom behavior of a viewport.
public protocol ViewportDelegate: AnyObject {

  /// Notifies the delegate that the viewport recieved a key press event.
  func didKeyPress<E>(viewport: Viewport, event: E) where E: KeyEventProtocol

  /// Notifies the delegate that the viewport recieved a key release event.
  func didKeyRelease<E>(viewport: Viewport, event: E) where E: KeyEventProtocol

  /// Notifies the delegate that the viewport recieved a mouse press event.
  func didMousePress<E>(viewport: Viewport, event: E) where E: MouseEventProtocol

  /// Notifies the delegate that the viewport recieved a mouse release event.
  func didMouseRelease<E>(viewport: Viewport, event: E) where E: MouseEventProtocol

}

// MARK: Default implementations

extension ViewportDelegate {

  public func didKeyPress<E>(viewport: Viewport, event: E) where E: KeyEventProtocol {
    viewport.nextResponder?.respondToKeyPress(with: event)
  }

  public func didKeyRelease<E>(viewport: Viewport, event: E) where E: KeyEventProtocol {
    viewport.nextResponder?.respondToKeyRelease(with: event)
  }

  public func didMousePress<E>(viewport: Viewport, event: E) where E: MouseEventProtocol {
    viewport.nextResponder?.respondToMousePress(with: event)
  }

  public func didMouseRelease<E>(viewport: Viewport, event: E) where E: MouseEventProtocol {
    viewport.nextResponder?.respondToMouseRelease(with: event)
  }

}
