/// A a raycast query.
public struct RaycastQuery: IteratorProtocol, Sequence {

  /// The ray to cast, defined in the scene's coordinate space.
  public private(set) var ray: Ray

  /// The nodes with which ray collision should be tested.
  public private(set) var nodes: Node.NodeIterator

  /// The categories of collision shapes with which the ray should interact.
  public let collisionMask: CollisionMask

  /// Returns the elements of the sequence, sorted.
  public func sorted() -> [(node: Node, collisionDistance: Double)] {
    return sorted(by: { a, b in a.collisionDistance < b.collisionDistance })
  }

  public mutating func next() -> (node: Node, collisionDistance: Double)? {
    while let node = nodes.next() {
      // Check if the ray should interact with the node.
      guard (node.collisionMask.rawValue & collisionMask.rawValue) != 0
        else { continue }

      // Check if the ray hits the node's collision shape.
      if let distance = node.collisionShape?.collisionDistance(
        with: ray,
        translation: node.sceneTranslation,
        rotation: node.sceneRotation,
        scale: node.sceneScale,
        isCullingEnabled: false)
      {
        return (node: node, collisionDistance: distance)
      }
    }

    return nil
  }

}
