/// The severity of a logged message.
public enum LogLevel: Int, Hashable {

  /// A message that is intended to provide debugging information.
  case debug = 0

  /// A message that relates to a potential problem.
  case warning

  /// A message that relates to an error that impedes the normal execution of the application.
  case error

  /// A message that relates to an error that causes the application to halt.
  case fatal

}

extension LogLevel: Comparable {

  public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

}
