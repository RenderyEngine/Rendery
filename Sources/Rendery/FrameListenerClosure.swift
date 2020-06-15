/// A frame listener that wraps a closure and uses it as its callback.
public final class FrameListenerClosure: FrameListener {

  /// Initializes a frame listener with a closure that implements its callback.
  ///
  /// - Parameter frameWillRender: A closure that implements the frame listener's behavior.
  public init(_ frameWillRender: @escaping (Milliseconds, Milliseconds) -> Void) {
    self.closure = frameWillRender
  }

  public func frameWillRender(currentTime: Milliseconds, delta: Milliseconds) {
    closure(currentTime, delta)
  }

  // MARK: Internal API

  /// The wrapped closure.
  private let closure: (Milliseconds, Milliseconds) -> Void

}
