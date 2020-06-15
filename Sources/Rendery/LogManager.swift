/// A log manager.
open class LogManager {

  /// Initializes a log manager.
  ///
  /// - Parameter logs: The logs the manager should register.
  public init(logs: [Log] = []) {
    self.logs = logs
  }

  /// The logs registered by the manager.
  public var logs: [Log]

  /// Writes the specified message to all registered logs.
  ///
  /// - Parameters:
  ///   - message: The message to write.
  ///   - level: The severity of the log message.
  open func log(_ message: String, level: LogLevel = .debug) {
    for log in logs {
      log.log(message, level: level)
    }
  }

  /// Writes an error value to all registered logs.
  ///
  /// - Parameters:
  ///   - error: The error value to log.
  ///   - level: The severity of the log message.
  open func log<E>(_ error: E, level: LogLevel = .error) where E: Error {
    log(String(describing: error), level: level)
  }

  /// The main log manager.
  public static let main = LogManager(logs: [DefaultLog()])

}
