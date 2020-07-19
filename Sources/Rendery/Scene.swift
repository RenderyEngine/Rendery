/// An object that organizes the contents of a scene hierarchically.
///
/// - Important: Make sure your scene does **not** retain any strong reference to the a window or
///   any of its viewports. This would result in a strong reference cycle.
open class Scene {

  /// Initializes a new, empty scene.
  public init() {
  }

  /// The color of the scene's background.
  ///
  /// When this property is `nil`, the scene's background is not cleared to any color. Instead, it
  /// is simply rendered over the surface covered by its viewport.
  ///
  /// - Note: For reasons of performance, it is recommended to leave this property unassigned and
  ///   modify the background color of your rendering surface instead, unless you wish to render
  ///   different scenes with different background onto the same surface.
  open var backgroundColor: Color? = nil

  /// The root of scene tree.
  open lazy var root = Node(scene: self)

  /// The scene's ambient light.
  ///
  /// The ambient light is an omni-directional light source that affects all objects in the scene
  /// equally, regardless of their position and/or orientation. It simulates the light produced by
  /// some distant light source (e.g., the moon).
  ///
  /// This property is set to `.white` by default, meaning that all objects in the scene are
  /// rendered completely illuminated. Assign a lower value if you wish to render more realistic
  /// light sources in your scene.
  ///
  /// - Note: As for all light sources, the ambient light's alpha component is ignored.
  open var ambientLight: Color = .white

  /// Casts a ray into the scene to find the nodes whose collision shape intersects with it.
  ///
  /// - Parameters:
  ///   - ray: A ray to cast.
  ///   - collisionMask: A mask defining the categories of collision shapes with which the ray
  ///     should interact.
  open func cast(ray: Ray, collisionMask: CollisionMask = .all) -> RaycastQuery {
    return RaycastQuery(
      ray: ray,
      nodes: Node.NodeIterator(root: root),
      collisionMask: collisionMask)
  }

  /// A callback method that is called when the scene is about to be presented by a viewport.
  ///
  /// This method is intended to be overridden to implement any custom behavior before the scene is
  /// ready to be rendered. For instance, you may use this method to create the scene's contents.
  ///
  /// Unless your scene is intended to be shown often, it is recommended to load its resources in
  /// this method (and unload them in `willMove(from:successor)` if you assign them to instance
  /// properties), rather than in its initializer. Doing so will ensure that graphics resources
  /// that are no longer needed are unloaded from the GPU memory.
  ///
  /// - Parameter viewport: The viewport that is presenting this scene.
  open func willMove(to viewport: Viewport) {
  }

  /// A callback method that is called when the scene is about to be removed from a viewport.
  ///
  /// This method is intended to be overridden to implement any custom behavior just before the
  /// scene is removed from a viewport.
  ///
  /// - Parameters:
  ///   - viewport: The viewport that is currently presenting the scene.
  ///   - successor: The scene that will replace the current one, if any.
  open func willMove(from viewport: Viewport, successor: Scene?) {
  }

  // MARK: Nodes

  open func createNode() -> Node {
    return Node(scene: self)
  }

  // MARK: Node constraints

  /// A cache that stores the generation number of the rendering loop at which a node's constraints
  /// have been last updated.
  internal final var constraintCache: [Node: UInt64] = [:]

  /// Applies the transformation constraints on `node`.
  internal final func updateConstraints(on node: Node, generation: UInt64) {
    guard constraintCache[node, default: 0] < generation
      else { return }

    for constraint in node.constraints {
      for dependency in constraint.dependencies {
        updateConstraints(on: dependency, generation: generation)
      }
      constraint.apply(on: node)
    }

    constraintCache[node] = generation
  }

}

