/// An object that appear in a responder chain that handles input events.
public protocol InputResponder: AnyObject {

  /// The next input responder after this one, or `nil` if it has none.
  var nextResponder: InputResponder? { get }

  /// Notifies the responder that a key has been pressed.
  func respondToKeyPress<E>(with: E) where E: KeyboardEventProtocol

  /// Notifies the responder that a key has been released.
  func respondToKeyRelease<E>(with: E) where E: KeyboardEventProtocol

}
