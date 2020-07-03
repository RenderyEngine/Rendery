/// A node that can be placed within the hierarchy of a scene tree.
public final class Node {

  /// Initializes an empty 3D node.
  internal init(scene: Scene) {
    self.scene = scene
  }

  /// The node's name.
  ///
  /// This property can be used to identify a node. For instance, you may search for a node in a
  /// scene tree by its name.
  public var name: String?

  /// The node's tags.
  ///
  /// This property can be used to identify a node. You may typically use it in to search for a set
  /// of nodes in a scene tree.
  public var tags: Set<String> = []

  /// A container for custom data.
  ///
  /// This property can be used to store your own data in a node. For instance, you may store a set
  /// of custom properties that your scene can uses when responding to a ray query.
  public var userData: [String: Any]?

  // MARK: Scene tree

  /// The scene to which the node belongs.
  public unowned let scene: Scene

  /// The node's parent.
  public private(set) weak var parent: Node? {
    didSet { shouldUpdateSceneProperties = true }
  }

  /// The node's children.
  public private(set) var children: [Node] = []

  /// Creates a new child node.
  public func createChild() -> Node {
    let child = Node(scene: scene)
    child.parent = self
    children.append(child)

    return child
  }

  /// Creates a new child node.
  ///
  /// - Parameter setup: A closure that accepts the newly created child to setup its properties.
  @discardableResult
  public func createChild(suchThat setup: (Node) throws -> Void) rethrows -> Node {
    let child = Node(scene: scene)
    child.parent = self
    children.append(child)

    try setup(child)
    return child
  }

  /// Creates multiple new children nodes.
  ///
  /// - Parameters:
  ///   - count: The number of children to create.
  ///   - setup: A closure that successively accepts each newly created child to setup its
  ///     properties.
  @discardableResult
  public func createChildren(
    count: Int,
    suchThat setup: (_ node: Node, _ offset: Int) throws -> Void
  ) rethrows -> [Node] {
    return try (0 ..< count).map({ offset in
      let child = Node(scene: scene)
      child.parent = self
      children.append(child)

      try setup(child, offset)
      return child
    })
  }

  /// Adds an already existing node as child.
  ///
  /// - Parameter child: The child to add.
  public func add(child: Node) {
    child.removeFromParent()
    child.parent = self
    children.append(child)
  }

  /// Removes the node from its parent.
  public func removeFromParent() {
    if let i = parent?.children.lastIndex(where: { child in child === self }) {
      parent!.children.remove(at: i)
    }
    parent = nil
  }

  /// Search for ancestor nodes satisfying the specified criterion, from parent to root.
  ///
  /// - Parameter criterion: The criterion the ancestor nodes should satisfy to be returned.
  public func ancestors(_ criterion: NodeFilterCriterion? = nil) -> [Node] {
    var result: [Node] = []
    var current = self
    while let next = current.parent {
      if criterion == nil || criterion!.isSatisfied(by: next) {
        result.append(next)
      }
      current = next
    }
    return result
  }

  /// Returns whether this node is a descendant of the specified ancestor.
  ///
  /// - Parameter ancestor: The node for which ancestorship shoup be checked.
  public func isDescendant(of ancestor: Node) -> Bool {
    guard let parent = self.parent
      else { return false }
    return (parent === ancestor) || parent.isDescendant(of: ancestor)
  }

  /// Searches for nodes satisfying the specified criterion in the scene tree rooted by this node.
  ///
  /// - Parameters:
  ///   - criterion: The criterion the descendant nodes should satisfy to be returned.
  ///   - pruningCriterion: A criterion that is used to exclude from the search all the subtrees
  ///     rooted by the nodes that do not satisfy it.
  public func descendants(
    _ criterion: NodeFilterCriterion? = nil,
    pruning pruningCriterion: NodeFilterCriterion? = nil
  ) -> NodeIterator {
    return NodeIterator(
      root: self,
      includeRoot: false,
      criterion: criterion,
      pruning: pruningCriterion)
  }

  /// A sequence that iterates over the nodes of a scene tree.
  public struct NodeIterator: IteratorProtocol, Sequence {

    public init(
      root: Node,
      includeRoot: Bool = true,
      criterion: NodeFilterCriterion? = nil,
      pruning pruningCriterion: NodeFilterCriterion? = nil
    ) {
      self.stack = includeRoot
        ? [root]
        : root.children.reversed()
      self.criterion = criterion
      self.pruningCriterion = pruningCriterion
    }

    private var stack: [Node]

    private let criterion: NodeFilterCriterion?

    private let pruningCriterion: NodeFilterCriterion?

    public var first: Node? {
      var iterator = makeIterator()
      return iterator.next()
    }

    public mutating func next() -> Node? {
      while let node = stack.popLast() {
        let isIncluded = criterion == nil || criterion!.isSatisfied(by: node)
        if pruningCriterion == nil || !pruningCriterion!.isSatisfied(by: node) {
          stack.append(contentsOf: node.children.reversed())
        }

        if isIncluded {
          return node
        }
      }

      return nil
    }

  }

  // MARK: Transform

  /// The node's translation, relative to its parent coordinate space.
  ///
  /// Each component of the vector defines a translation along the corresponding axis, in the
  /// parent coordinate space. This means that translating a node along its local x-axis when its
  /// parent is rotated by 90° around the global y-axis will actually move the child along the
  /// z-axis in the scene coordinate space. The default translation is the zero vector.
  public var translation: Vector3 = .zero {
    didSet { shouldUpdateSceneProperties = true }
  }

  /// The node's translation, relative to the scene coordinate space.
  public var sceneTranslation: Vector3 {
    if shouldUpdateSceneProperties {
      updateSceneProperties()
    }
    return _sceneTranslation
  }

  /// The cached scene translation.
  private var _sceneTranslation: Vector3 = .zero

  /// The node's rotation, relative to its parent coordinate space.
  ///
  /// This property is stored as a rotation quaternion (i.e. a quaternion whose length is one). The
  /// may get other representations of the node's rotation by converting this quaternion to an
  /// equivalent data structure (e.g. an axis-angle pair).
  public var rotation: Quaternion = .identity {
    didSet { shouldUpdateSceneProperties = true }
  }

  /// The node's rotation, relative to the scene coordinate space.
  public var sceneRotation: Quaternion {
    if shouldUpdateSceneProperties {
      updateSceneProperties()
    }
    return _sceneRotation
  }

  /// The cached scene rotation.
  private var _sceneRotation: Quaternion = .identity

  /// The node's scale, relative to its parent coordinate space.
  ///
  /// Each component of the vector multiplies the corresponding dimension of the node's geometry.
  /// The default scale is `1.0` in all three dimensions.
  public var scale: Vector3 = .unitScale {
    didSet { shouldUpdateSceneProperties = true }
  }

  /// The node's scale, relative to the scene coordinate space.
  public var sceneScale: Vector3 {
    if shouldUpdateSceneProperties {
      updateSceneProperties()
    }
    return _sceneScale
  }

  /// The cached scene scale.
  private var _sceneScale: Vector3 = .unitScale

  /// A matrix combining the scene scale factor, rotation and translation of this node.
  public var sceneTransform: Matrix4 {
    if let matrix = _sceneTransform {
      return matrix
    }

    _sceneTransform = Matrix4(
      translation: sceneTranslation,
      rotation: sceneRotation,
      scale: sceneScale)
    return _sceneTransform!
  }

  /// The cached scene transform.
  private var _sceneTransform: Matrix4? = .identity

  /// A flag indicating whether the scene transform properties of this node should be updated.
  private var shouldUpdateSceneProperties: Bool = false {
    didSet {
      // Invalidate the scene transformation matrix.
      _sceneTransform = nil

      // Notify all children that their scene tranform properties should be updated.
      for child in children {
        child.shouldUpdateSceneProperties = true
      }
    }
  }

  /// Updates the node's scene transform properties.
  private func updateSceneProperties() {
    // Update the scene transforms, unless the node is an orphan.
    if let parent = self.parent {
      // Note that we post-multiply, since the matrix are stored as column-major.
      _sceneScale = parent.sceneScale * scale
      _sceneRotation = parent.sceneRotation * rotation

      // Compute the derived translation after applying the parent's global scale and rotation.
      let derivedTranslation = parent.sceneRotation * (parent.sceneScale * translation)
      _sceneTranslation = derivedTranslation + parent.sceneTranslation
    } else {
      // If the node is an orphan, then its scene transform is equal to its local transform.
      _sceneScale = scale
      _sceneRotation = rotation
      _sceneTranslation = translation
    }

    shouldUpdateSceneProperties = false
  }

  /// The node's transform constraints.
  ///
  /// You may add a transform constraint to automatically control the transform properties of a
  /// node so that they satisfy a set of relationships. You may for instance constrain a node so
  /// that it remains oriented to another node, regardless of its parent's transform.
  ///
  /// - Note: Transform constraints are applied during the rendering loop, __after__ the frame
  ///   listeners have been notified, and not when they are set, nor when you manually assign any
  ///   transform properties. Hence, if you read transform properties of a node under constraint
  ///   to update your scene behavior from a frame listener, keep in mind that their values will
  ///   correspond to the results from the last frame.
  public var constraints: [TransformConstraint] = [] {
    didSet {
      // Invalidate the constraint cache for this node.
      scene.constraintCache[self] = 0
    }
  }

  // MARK: Visual behavior

  /// The camera attached to this node.
  public var camera: Camera?

  /// The model attached to this node.
  ///
  /// Setting this property automatically assignes the model's bounding box to `collisionShape`.
  public var model: Model? {
    didSet {
      collisionShape = model?.aabb
    }
  }

  /// The light source attached to this node.
  public var light: Light?

  /// A flag that indicates whether the node and its children are hidden.
  ///
  /// If a node or one of its parent is hidden, then nor the node's model nor its light will be
  /// rendered into the scene. Other properties, such as cameras and collisions shapes, are not
  /// affected by the value of this property.
  public var isHidden: Bool = false

  // MARK: Collision behavior

  /// The node's collision shape.
  ///
  /// The collision shape is the volume that is used for collision testing. Nodes to which a model
  /// is attached are given a bounding box of the model as their default collision shape. You may
  /// substitute it for a different collision shape, typically to provide a more accurate
  /// approximation of the model's geometry.
  ///
  /// You may also assign a collision shape to a node without any model, so that it also respond to
  /// collision testing. This can be useful to implement invisible sensors.
  public var collisionShape: CollisionShape?

  /// The node's collision mask.
  ///
  /// This property defines the categories of collision objects to which this node belongs. When
  /// rendery performs collision testing, it first checks if the collider belongs to the same
  /// category before searching for an intersection.
  public var collisionMask: CollisionMask = .default

}

extension Node: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  public static func == (lhs: Node, rhs: Node) -> Bool {
    return lhs === rhs
  }

}
