/// A set of modifier keys.
public struct KeyModifierSet: OptionSet {

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public let rawValue: Int

  /// No modifiers.
  public static var none = KeyModifierSet(rawValue: 0)

  /// The shift (⇧) modifier.
  public static let shift = KeyModifierSet(rawValue: 1 << 0)

  /// The control (⌃) modifier.
  public static let control = KeyModifierSet(rawValue: 1 << 1)

  /// The option (⌥) modifier.
  public static let option = KeyModifierSet(rawValue: 1 << 2)

  /// The command (⌘) modifier.
  public static let command = KeyModifierSet(rawValue: 1 << 3)

  /// The caps lock modifier.
  public static let capsLock = KeyModifierSet(rawValue: 1 << 4)

  /// The num lock modifier.
  public static let numLock = KeyModifierSet(rawValue: 1 << 5)

  // MARK: Alternative names

  public static var alt    : KeyModifierSet { option }
  public static var windows: KeyModifierSet { command }

}
