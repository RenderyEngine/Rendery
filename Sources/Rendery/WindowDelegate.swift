/// A type that implements the custom behavior of a window.
public protocol WindowDelegate: AnyObject {

  /// Notifies the delegate that the window is about to close.
  func windowWillClose(window: Window)

  /// Notifies the delegate that the window closed.
  func windowDidClose(window: Window)

  /// Notifies the delegate that the window has been resized.
  func windowDidResize(window: Window)

  /// Notifies the delegate that the window received focus.
  func windowDidReceiveFocus(window: Window)

  /// Notifies the delegate that the window lost focus.
  func windowDidLostFocus(window: Window)

  /// Notifies the delegate that the window recieved a key press event.
  func windowDidReceiveKeyPress<E>(window: Window, event: E) where E: KeyEventProtocol

  /// Notifies the delegate that the window recieved a key release event.
  func windowDidReceiveKeyRelease<E>(window: Window, event: E) where E: KeyEventProtocol

  /// Notifies the delegate that the window recieved a mouse press event.
  func windowDidReceiveMousePress<E>(window: Window, event: E) where E: MouseEventProtocol

  /// Notifies the delegate that the window recieved a mouse release event.
  func windowDidReceiveMouseRelease<E>(window: Window, event: E) where E: MouseEventProtocol

}

// MARK: Default implementations

extension WindowDelegate {

  public func windowWillClose(window: Window) {
  }

  public func windowDidClose(window: Window) {
  }

  public func windowDidResize(window: Window) {
  }

  public func windowDidReceiveFocus(window: Window) {
  }

  public func windowDidLostFocus(window: Window) {
  }

  public func windowDidReceiveKeyPress<E>(window: Window, event: E)
    where E: KeyEventProtocol
  {
    window.nextResponder?.respondToKeyPress(with: event)
  }

  public func windowDidReceiveKeyRelease<E>(window: Window, event: E)
    where E: KeyEventProtocol
  {
    window.nextResponder?.respondToKeyRelease(with: event)
  }

  public func windowDidReceiveMousePress<E>(window: Window, event: E)
    where E: MouseEventProtocol
  {
    window.nextResponder?.respondToMousePress(with: event)
  }

  public func windowDidReceiveMouseRelease<E>(window: Window, event: E)
    where E: MouseEventProtocol
  {
    window.nextResponder?.respondToMouseRelease(with: event)
  }

}
