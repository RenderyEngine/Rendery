public struct VertexAttributeDescriptor {

  public init(
    offset: Int,
    stride: Int,
    semantic: Semantic,
    componentCountPerVertex: Int,
    componentType: Any.Type,
    shaderLocation: Int
  ) {
    self.offset = offset
    self.stride = stride
    self.shaderLocation = shaderLocation
    self.componentCountPerVertex = componentCountPerVertex
    self.componentType = componentType
    self.semantic = semantic
  }

  /// The offset in bytes, from the beginning of the data to the first attribute in the source.
  public let offset: Int

  /// The number of bytes from an attribute to the next in the source.
  public let stride: Int

  /// The semantic of the attributes.
  public let semantic: Semantic

  /// The semantic of a vertex attribute.
  public enum Semantic: Hashable {

    /// Vertex position data.
    ///
    /// The corresponding components should form triplets of `Float` values..
    case position

    /// Surface normal data.
    case normal

    /// Texture coordinate data.
    case textureCoordinates

    /// Vertex color data.
    case color

    /// Surface tangent vector data.
    case tangent

    /// Custom user data.
    case custom(name: String)

  }

  /// The number of components per vertex that describe the attribute.
  public let componentCountPerVertex: Int

  /// The type of a single vertex attribute component.
  public let componentType: Any.Type

  /// The shader location to which the attributes should be bound.
  public let shaderLocation: Int

}
