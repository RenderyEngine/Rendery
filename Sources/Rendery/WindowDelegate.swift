/// A type that implements the custom behavior of a window.
public protocol WindowDelegate: AnyObject {

  /// Notifies the delegate that the window is about to close.
  func willClose(window: Window)

  /// Notifies the delegate that the window closed.
  func didClose(window: Window)

  /// Notifies the delegate that the window has been resized.
  func didResize(window: Window)

  /// Notifies the delegate that the window received focus.
  func didReceiveFocus(window: Window)

  /// Notifies the delegate that the window lost focus.
  func didLostFocus(window: Window)

  /// Notifies the delegate that the window recieved a key press event.
  func didKeyPress<E>(window: Window, event: E) where E: KeyEventProtocol

  /// Notifies the delegate that the window recieved a key release event.
  func didKeyRelease<E>(window: Window, event: E) where E: KeyEventProtocol

  /// Notifies the delegate that the window recieved a mouse press event.
  func didMousePress<E>(window: Window, event: E) where E: MouseEventProtocol

  /// Notifies the delegate that the window recieved a mouse release event.
  func didMouseRelease<E>(window: Window, event: E) where E: MouseEventProtocol

}

// MARK: Default implementations

extension WindowDelegate {

  public func willClose(window: Window) {
  }

  public func didClose(window: Window) {
  }

  public func didResize(window: Window) {
  }

  public func didReceiveFocus(window: Window) {
  }

  public func didLostFocus(window: Window) {
  }

  public func didKeyPress<E>(window: Window, event: E) where E: KeyEventProtocol {
    window.nextResponder?.respondToKeyPress(with: event)
  }

  public func didKeyRelease<E>(window: Window, event: E) where E: KeyEventProtocol {
    window.nextResponder?.respondToKeyRelease(with: event)
  }

  public func didMousePress<E>(window: Window, event: E) where E: MouseEventProtocol {
    window.nextResponder?.respondToMousePress(with: event)
  }

  public func didMouseRelease<E>(window: Window, event: E) where E: MouseEventProtocol {
    window.nextResponder?.respondToMouseRelease(with: event)
  }

}
