/// A structure that keeps track of the state of all user inputs (i.e., keyboard, mouse, etc.).
public struct InputState {

  /// Returns whether the specified key is being pressed.
  ///
  /// - Parameter code: The layout-independant code that identifying the desired key.
  public func isPressed(key keyCode: Int) -> Bool {
    return keyPressed.contains(keyCode)
  }

  /// A set identifying which keys are being pressed.
  internal var keyPressed: Set<Int> = []

}
