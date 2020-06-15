/// A listener that can observe frame events.
public protocol FrameListener: AnyObject {

  /// A callback method that is called at the beginning of each rendering cycle.
  ///
  /// - Parameters:
  ///   - currentTime: The current system time, in milliseconds.
  ///   - delta: The time interval since the last frame event.
  func frameWillRender(currentTime: Milliseconds, delta: Milliseconds)

}
