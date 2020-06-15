/// A graphics resource manager.
internal final class GraphicsResourceManager {

  /// Initializes a graphics resource manager.
  public init() {
  }

  /// The set of graphics resources stored by this manager.
  ///
  /// Resources are stored in a dictionary indexed by their address in memory, to guarantee their
  /// uniqueness.
  private var resources: [ObjectIdentifier: ResourceWeakRef] = [:]

  /// A storable weak reference to a graphics resource object.
  fileprivate struct ResourceWeakRef {

    fileprivate init(_ resource: GraphicsResource?) {
      self.resource = resource
    }

    weak var resource: GraphicsResource?

  }

  /// Stores the specified graphics resource, bounding its lifetime to that of the manager.
  ///
  /// This method has no effect if `resource` was already stored.
  ///
  /// - Parameter resource: The graphics resource to store.
  internal func store(_ resource: GraphicsResource) {
    resources[ObjectIdentifier(resource)] = ResourceWeakRef(resource)
  }

  /// Removes the specified graphics resouce from the manager.
  ///
  /// This method is intended to be used internally by a resource deinitializer.
  ///
  /// - Parameter resource: The graphics resource to remove.
  internal func remove(_ resource: GraphicsResource) {
    resources[ObjectIdentifier(resource)] = nil
  }

  /// Unloads all graphics resources.
  internal func unloadAllResources() {
    for ref in resources.values {
      ref.resource?.unload()
    }
    resources = [:]
  }

  /// Cleans dead references to disposed graphics resources.
  ///
  /// Disposable resources are stored as weak references so that their instance can be unloaded
  /// through their deinitializer once they are no longer externally retained. However, while the
  /// manager will not keep the resource instance alive, it will not automatically get rid of its
  /// reference. This has no functional impact but may have a memory/performance impact if the
  /// manager's internal storage contains too many unused dead references, slowing down its its
  /// lookup mechanism.
  ///
  /// This method filters out every weak reference to a deinitialized resource. Nonetheless, keep
  /// in mind that any sort of memory/performance impact should not be noticeable before a very
  /// large number of disposable resources have been automatically unloaded. Hence, prematurely
  /// calling this method will actually hinder performance.
  internal func cleanUnusedReferences() {
    resources = resources.filter({ (_, ref) in ref.resource != nil })
  }

  /// The counter that's used to generate unique identifiers.
  private var nextID: UInt64 = 0

  deinit {
    unloadAllResources()
  }

}

// MARK:- Conformance to Collection

extension GraphicsResourceManager: Collection {

  public var startIndex: GraphicsResourceManager.Index { Index(value: resources.values.startIndex) }

  public var endIndex: GraphicsResourceManager.Index { Index(value: resources.values.endIndex) }

  public func index(after i: GraphicsResourceManager.Index) -> GraphicsResourceManager.Index {
    return Index(value: resources.values.index(after: i.value))
  }

  public subscript(position: GraphicsResourceManager.Index) -> GraphicsResource? {
    return resources.values[position.value].resource
  }

  public struct Index: Comparable {

    fileprivate var value: Dictionary<ObjectIdentifier, ResourceWeakRef>.Values.Index

    public static func < (lhs: Index, rhs: Index) -> Bool {
      return lhs.value < rhs.value
    }

  }

}
