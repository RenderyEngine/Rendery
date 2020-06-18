/// A key/gamepad event.
public struct KeyEvent: InputEvent {

  /// A flag that indicates if the event is a repeat caused by the user holding the key down.
  public let isRepeat: Bool

  /// The modifier keys that were pressed when the event occured.
  public let modifiers: KeyModifierSet

  /// The code of the key related to the event.
  ///
  /// This property represents a layout-independent key code (as opposed to the character it may
  /// generate) that designates the key that has been pressed or released. It can be used to handle
  /// keys based on their physical location on the keyboard rather than their semantic (e.g. to map
  /// keys to a specific set of game inputs).
  ///
  /// - Important: Do not use this property to determine character inputs.
  public let code: Int

  /// A symbolic, printable representation of the key ressed by the user.
  ///
  /// The value of this property depends on the keyboard layout.
  ///
  /// - Important: Do not use this property to determine character inputs.
  public let symbol: String?

  public unowned let firstResponder: InputResponder?

  public let timestamp: Milliseconds

  public var userData: [String: Any]?

}
