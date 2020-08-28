extension Material.Property {

  /// Assigns this material property at `location` in `program`.
  ///
  /// - Parameters:
  ///   - location: The location of the uniform to which the property should be assigned.
  ///   - textureUnit: The unit that should be used to bind the property's texture.
  ///   - program: The program in which the value should be assigned.
  public func assign(to location: String, textureUnit: Int, in program: GLSLProgram) {
    switch self {
    case .color(let color):
      program.assign(color, to: "\(location).color", discardingAlpha: false)
      program.assign(Texture.default, to: "\(location).texture", textureUnit: textureUnit)

    case .texture(let texture):
      program.assign(Color.white, to: "\(location).color", discardingAlpha: false)
      program.assign(texture, to: "\(location).texture", textureUnit: textureUnit)
    }
  }

}
