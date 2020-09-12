/// A light entity.
public struct LightEntity {

  /// Initializes a light entity.
  ///
  /// - Parameters:
  ///   - light: The 3D light source's description.
  ///   - translation: The entity's translation, in the scene coordinate space.
  ///   - rotation: The entity's rotation, in the scene coordinate space.
  public init(light: Light, translation: Vector3, rotation: Quaternion) {
    self.light = light
    self.translation = translation
    self.rotation = rotation
  }

  /// Initializes a light entity from a node to which a light is attached.
  ///
  /// - Parameter node: A node to wich a 3D light is attached.
  public init?(node: Node) {
    guard let light = node.light
      else { return nil }
    self.init(light: light, translation: node.sceneTranslation, rotation: node.sceneRotation)
  }

  /// The entity's light component.
  public let light: Light

  /// The entity's translation, in the scene coordinate space.
  public let translation: Vector3

  /// The entity's rotation, in the scene coordinate space.
  public let rotation: Quaternion

  /// The light's shadow map.
  public var shadowMap: MutableTexture?

  /// The light's view-projection matrix.
  public var viewProjMatrix: Matrix4?

}
