/// A structure that keeps track of the state of all user inputs (i.e., keyboard, mouse, etc.).
public struct InputState {

  /// Returns whether the specified key is being pressed.
  ///
  /// - Parameter code: The layout-independant code that identifies the desired key.
  public func isPressed(key keyCode: Int) -> Bool {
    return keyPressed.contains(keyCode)
  }

  /// Returns whether the specified mouse button is being pressed.
  ///
  /// - Parameter buttonCode: The code that identifies the desired button.
  public func isPressed(mouseButton buttonCode: Int) -> Bool {
    return mouseButtonPressed.contains(buttonCode)
  }

  /// A set identifying which keys are being pressed.
  internal var keyPressed: Set<Int> = []

  /// A set identifying which mouse buttons are being pressed.
  internal var mouseButtonPressed: Set<Int> = []

}
