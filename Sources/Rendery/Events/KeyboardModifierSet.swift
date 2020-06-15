/// A set of modifier keys.
public struct KeyboardModifierSet: OptionSet {

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public let rawValue: Int

  /// No modifiers.
  public static var none = KeyboardModifierSet(rawValue: 0)

  /// The shift (⇧) modifier.
  public static let shift = KeyboardModifierSet(rawValue: 1 << 0)

  /// The control (⌃) modifier.
  public static let control = KeyboardModifierSet(rawValue: 1 << 1)

  /// The option (⌥) modifier.
  public static let option = KeyboardModifierSet(rawValue: 1 << 2)

  /// The command (⌘) modifier.
  public static let command = KeyboardModifierSet(rawValue: 1 << 3)

  /// The caps lock modifier.
  public static let capsLock = KeyboardModifierSet(rawValue: 1 << 4)

  /// The num lock modifier.
  public static let numLock = KeyboardModifierSet(rawValue: 1 << 5)

  // MARK: Alternative names

  public static var alt    : KeyboardModifierSet { option }
  public static var windows: KeyboardModifierSet { command }

}
