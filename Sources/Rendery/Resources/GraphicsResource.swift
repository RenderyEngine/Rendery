/// A graphics resource that must be loaded into GPU memory.
///
/// This protocol provides an abstraction layer to deal with the lifecycle of data objects that
/// must be loaded into GPU memory (e.g., a texture). It defines the interface of a state automaton
/// that describes this lifecycle.
internal protocol GraphicsResource: AnyObject {

  /// The resource's current state.
  var state: GraphicsResourceState { get }

  /// Loads the resource.
  ///
  /// - Note: This method is idempotent. The resource may be in any loading state but `gone`.
  func load() throws

  /// Unloads the resource.
  ///
  /// - Note: This method is idempotent.
  func unload()

}
