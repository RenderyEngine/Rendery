/// An object that describes a single input event.
public protocol InputEvent {

  /// The first responder for this event.
  ///
  /// This property designates the first object that responded to the event, that is the object to
  /// which the event was originally dispatched.
  var firstResponder: InputResponder? { get }

  /// The time when the event occured.
  var timestamp: Milliseconds { get }
}
