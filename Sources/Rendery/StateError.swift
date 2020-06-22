/// An error that occurred because an operation was not allowed by the current state of the
/// object(s) on which it was applied.
public struct StateError: Error {

  /// Initializes a state error.
  ///
  /// - Parameter reason: The reason for the error.
  public init(reason: String) {
    self.reason = reason
  }

  /// The reason for this error.
  public var reason: String

}
