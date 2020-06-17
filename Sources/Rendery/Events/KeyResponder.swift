/// An object that appear in a responder chain that handles key/gamepad input events.
public protocol KeyResponder: AnyObject {

  /// The next input responder after this one, or `nil` if it has none.
  var nextKeyResponder: KeyResponder? { get }

  /// Notifies the responder that a key has been pressed.
  func respondToKeyPress<E>(with: E) where E: KeyEventProtocol

  /// Notifies the responder that a key has been released.
  func respondToKeyRelease<E>(with: E) where E: KeyEventProtocol

}
