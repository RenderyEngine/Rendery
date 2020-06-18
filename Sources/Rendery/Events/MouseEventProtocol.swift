/// A type that represents a mouse event.
public protocol MouseEventProtocol: InputEvent {

  /// The modifier keys that were pressed when the event occured.
  var modifiers: KeyModifierSet { get }

  /// The code of the mouse button related to the event.
  var code: Int { get }

}
