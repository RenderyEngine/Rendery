/// A keyboard event
public struct KeyboardEvent: KeyboardEventProtocol {

  public let isRepeat: Bool

  public let modifiers: KeyboardModifierSet

  public let code: Int

  public let symbol: String?

  public unowned let firstResponder: InputResponder?

  public let timestamp: Milliseconds

}
