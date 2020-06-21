/// A frame listener that wraps a closure and uses it as its callback.
public final class FrameListenerClosure: FrameListener {

  public typealias Function = (_ currentTime: Milliseconds, _ delta: Milliseconds) -> Void

  /// Initializes a frame listener with a closure that implements its callback.
  ///
  /// - Parameter frameWillRender: A closure that implements the frame listener's behavior.
  public init(_ frameWillRender: @escaping Function) {
    self.closure = frameWillRender
  }

  public func frameWillRender(currentTime: Milliseconds, delta: Milliseconds) {
    closure(currentTime, delta)
  }

  // MARK: Internal API

  /// The wrapped closure.
  private let closure: Function

}
