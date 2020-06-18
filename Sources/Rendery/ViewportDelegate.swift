/// A type that implements the custom behavior of a viewport.
public protocol ViewportDelegate: AnyObject {

  /// Notifies the delegate that the viewport recieved a key press event.
  func didKeyPress(viewport: Viewport, event: KeyEvent)

  /// Notifies the delegate that the viewport recieved a key release event.
  func didKeyRelease(viewport: Viewport, event: KeyEvent)

  /// Notifies the delegate that the viewport recieved a mouse press event.
  func didMousePress(viewport: Viewport, event: MouseEvent)

  /// Notifies the delegate that the viewport recieved a mouse release event.
  func didMouseRelease(viewport: Viewport, event: MouseEvent)

}

// MARK: Default implementations

extension ViewportDelegate {

  public func didKeyPress(viewport: Viewport, event: KeyEvent) {
    viewport.nextResponder?.respondToKeyPress(with: event)
  }

  public func didKeyRelease(viewport: Viewport, event: KeyEvent) {
    viewport.nextResponder?.respondToKeyRelease(with: event)
  }

  public func didMousePress(viewport: Viewport, event: MouseEvent) {
    viewport.nextResponder?.respondToMousePress(with: event)
  }

  public func didMouseRelease(viewport: Viewport, event: MouseEvent) {
    viewport.nextResponder?.respondToMouseRelease(with: event)
  }

}
