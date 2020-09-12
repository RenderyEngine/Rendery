/// A structure that contains settings related to the lighting of a scene.
public struct LightSettings {

  /// Initialize a set of light settings.
  ///
  /// - Parameters:
  ///   - ambient: The scene's ambient light.
  ///   - lightEntities: A sequence with the light entities presentin the scene.
  public init(ambient: Color, lightEntities: [LightEntity]) {
    self.ambient = ambient
    self.lightEntities = lightEntities
  }

  /// The scene's ambient light.
  public var ambient: Color

  /// The available light entities in the scene.
  public var lightEntities: [LightEntity]

  /// A function that is used to filter the lights that are affecting a node.
  ///
  /// You can use this property to filter the lights that are used to compute a model's lighting in
  /// its material shader.
  public var lightSelectionFilter: ((Node) -> [LightEntity])?

}
