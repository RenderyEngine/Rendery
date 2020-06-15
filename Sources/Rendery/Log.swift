/// An object that can records various events.
public protocol Log {

  /// Writes a message in this log.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - level: The severity of the log message.
  func log(_ message: String, level: LogLevel)

}
