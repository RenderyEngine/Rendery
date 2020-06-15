/// The loading state of a graphcs resource.
///
/// This enumeration defines the different states of a graphics resource's lifecycle. All resources
/// start in the `unloaded` state. From there, the precise semantics of each state may depend on
/// the concreate resource type, but generally:
/// - It moves to `loaded` when it has been loaded into GPU memory and is ready to be used.
/// - It either moves back to `unloaded` or moves to `gone` when its `unload()` method is called.
///   The latter state indicates that it cannot be reloaded (e.g. subsequent calls to `load()`
///   should fail).
internal enum GraphicsResourceState {

  /// The resource is unloaded; it can be loaded by calling its `load()` method.
  case unloaded

  /// The resource is loaded and ready to be used.
  case loaded

  /// The resource is no longer available; subsequent calls to `load()` should fail.
  case gone

}
