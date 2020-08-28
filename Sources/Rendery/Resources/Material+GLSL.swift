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
      program.assign(color: color.linear(), at: "\(location).color", discardingAlpha: false)
      program.assign(texture: .default, to: "\(location).texture", at: textureUnit)

    case .texture(let texture):
      program.assign(color: .white, at: "\(location).color", discardingAlpha: false)
      program.assign(texture: texture, to: "\(location).texture", at: textureUnit)
    }
  }

}
