/// The material of a mesh.
///
/// A material controls how a 3D mesh appears on the screen. It is composed of a shader program
/// that is executed on the GPU to transform vertex data into pixels. This program usually takes
/// additional parameters, called *material properties*, such as textures and colors.
public struct Material {

  /// Initializes a material with a GLSL shader program.
  public init(program: GLSLProgram = .default) {
    self.shader = program
  }

  // The material's shader program.
  public var shader: GLSLProgram

  /// The material's diffuse response to lighting.
  public var diffuse: Property = .color(.white)

  /// A value that alters each texel after all other properties have been combined.
  ///
  /// Once the material's response to lighting has been computed, Rendery multiplies each texel's
  /// color with this value. You can use this property to modulate the color of an object (e.g., to
  /// tint a texture) regardless of other lighting effects, or to add precomputed lighting.
  public var multiply: Property = .color(.white)

  /// A material property.
  public enum Property {

    /// A color, which provides uniform effect across the surface of a material.
    case color(Color)

    /// A texture, which is mapped across the surgace of a material using the texture coordinates
    /// of the mesh to which the material is applied.
    case texture(Texture)

  }

}
