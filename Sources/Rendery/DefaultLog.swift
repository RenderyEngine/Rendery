/// A log that writes all messages to the standard output.
public struct DefaultLog: Log {

  public init() {
  }

  public func log(_ message: String, level: LogLevel) {
    switch level {
    case .debug   : print("Debug: \(message)")
    case .warning : print("Warning: \(message)")
    case .error   : print("Error: \(message)")
    case .fatal   : print("Fatal: \(message)")
    }
  }

}
