/// A generic mouse event.
public struct MouseEvent: MouseEventProtocol {

  public var modifiers: KeyModifierSet

  public let code: Int

  public unowned let firstResponder: InputResponder?

  public let timestamp: Milliseconds

}
