/// A mouse event.
public struct MouseEvent: InputEvent {

  /// The mouse button related to the event.
  public let button: Int

  /// The position of the cursor when the event occurred, in normalized window coordinates.
  public let cursorPosition: Vector2

  /// The modifier keys that were pressed when the event occurred.
  public let modifiers: KeyModifierSet

  public unowned let firstResponder: InputResponder?

  public let timestamp: Milliseconds

  public var userData: [String : Any]?

}
