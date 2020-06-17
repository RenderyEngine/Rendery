/// A key/gamepad event.
public struct KeyEvent: KeyEventProtocol {

  public let isRepeat: Bool

  public let modifiers: KeyModifierSet

  public let code: Int

  public let symbol: String?

  public unowned let firstResponder: KeyResponder?

  public let timestamp: Milliseconds

}
