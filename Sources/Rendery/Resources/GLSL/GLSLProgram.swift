import CGLFW

/// A GLSL program, compiled and loaded in GPU memory.
///
/// A shader is a program that is run by the GPU to transform vertex data into colored pixels. They
/// can be used to perform a variety of effects, ranging from simple texturing and lighting to more
/// elaborate post-processing operations.
public final class GLSLProgram: GraphicsResource {

  /// Initializes a shader program.
  ///
  /// - Parameter delegate: The program's delegate.
  public init(delegate: GLSLProgramDelegate) {
    self.delegate = delegate
    self.state = .unloaded
  }

  /// The program's delegate.
  public let delegate: GLSLProgramDelegate

  /// The maximum number of lights that are used when rendering.
  public var maxLightCount: Int { delegate.maxLightCount }

  /// A cache mapping uniform variable names to their location.
  private var locations: [String: Int32] = [:]

  /// Returns the location of a uniform variable.
  ///
  /// - Parameter name: The name of the uniform variable.
  public func location(of name: String) -> Int32 {
    if let location = locations[name] {
      return location
    }

    let location = glGetUniformLocation(handle, name)
    locations[name] = location
    return location
  }

  /// Assigns a boolean at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - boolean: The boolean value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign(_ boolean: Bool, to name: String) {
    let loc = location(of: name)
    glUniform1i(loc, boolean ? 1 : 0)
  }

  /// Assigns an integer at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - integer: The integer value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign(_ integer: Int, to name: String) {
    let loc = location(of: name)
    glUniform1i(loc, GL.Int(integer))
  }

  /// Assigns a float at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - float: The float value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign(_ float: Float, to name: String) {
    let loc = location(of: name)
    glUniform1f(loc, float)
  }

  /// Assigns a color value at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - color: The color value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  ///   - discardingAlpha: A flag that indicates whether the alpha channel should be discarded.
  public func assign(_ color: Color, to name: String, discardingAlpha: Bool = true) {
    let loc = location(of: name)
    if discardingAlpha {
      glUniform3f(loc, Float(color.red), Float(color.green), Float(color.blue))
    } else {
      glUniform4f(loc, Float(color.red), Float(color.green), Float(color.blue), Float(color.alpha))
    }
  }

  /// Assigns a 2D vector at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - vector2: The vector value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign(_ vector2: Vector2, to name: String) {
    let loc = location(of: name)
    glUniform2f(loc, Float(vector2.x), Float(vector2.y))
  }

  /// Assigns a 3D vector at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - vector3: The vector value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign(_ vector3: Vector3, to name: String) {
    let loc = location(of: name)
    glUniform3f(loc, Float(vector3.x), Float(vector3.y), Float(vector3.z))
  }

  /// Assigns a 3x3 matrix at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - matrix3: The matrix value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign(_ matrix3: @autoclosure () -> Matrix3, to name: String) {
    let loc = location(of: name)
    let data = matrix3().components.map(Float.init)
    glUniformMatrix3fv(loc, 1, 0, data)
  }

  /// Assigns a 4x4 matrix at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - matrix4: The matrix value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign(_ matrix4: @autoclosure () -> Matrix4, to name: String) {
    let loc = location(of: name)
    let data = matrix4().components.map(Float.init)
    glUniformMatrix4fv(loc, 1, 0, data)
  }

  /// Assigns a texture at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - color: The texture to assign.
  ///   - sampler: The name of the sampler to which the texture should be assigned.
  ///   - textureUnit: The unit to which the texture should be assigned.
  public func assign(_ texture: Texture, to sampler: String, textureUnit: Int) {
    // Activate the texture unit.
    glActiveTexture(GL.TEXTURE0 + UInt32(textureUnit))
    glBindTexture(GL.TEXTURE_2D, texture.handle)
    assign(textureUnit, to: sampler)
  }

  /// Assigns a meterial at the specified location.
  ///
  /// - Parameters:
  ///   - material: The material to assign.
  ///   - location: The name of the variable to which the material should be assigned.
  ///   - firstTextureUnit: The first of the units to which the material's textures should be
  ///     assigned.
  public func assign(_ material: Material, to location: String, firstTextureUnit: Int) {
    assign(material.diffuse, to: location + ".diffuse", textureUnit: 0)
    assign(material.multiply, to: location + ".multiply", textureUnit: 1)
  }

  /// Assigns a material property at the specified location.
  ///
  /// This method assigns both a color and a texture uniform. The value of each uniform depends on
  /// the material property's value. When the property's value is a color, it is assigned to the
  /// color uniform while the texture uniform is assigned to a default 1x1 white texture. When the
  /// property's value is a texture, it is assigned to the texture uniform while the color uniform
  /// is assigned to white.
  ///
  /// - Parameters:
  ///   - property: The property to assign.
  ///   - location: The prefix of the material property in a material uniform.
  ///   - textureUnit: The unit to which the texture should be assigned.
  private func assign(_ property: Material.Property, to location: String, textureUnit: Int) {
    switch property {
    case .color(let color):
      assign(color, to: "\(location)Color", discardingAlpha: false)
      assign(Texture.default, to: "\(location)Texture", textureUnit: textureUnit)

    case .texture(let texture):
      assign(Color.white, to: "\(location)Color", discardingAlpha: false)
      assign(texture, to: "\(location)Texture", textureUnit: textureUnit)
    }
  }

  /// Assigns a value at the specified location.
  ///
  /// - Parameters:
  ///   - value: The value to assign.
  ///   - name: The name of the variable to which the value should be assigned.
  public func assign<T>(
    _ value: @autoclosure () -> T,
    to name: String
  ) where T: GLSLAssignable {
    value().assign(to: name, in: self)
  }

  /// The default shader program.
  public static let `default` = GLSLProgram(delegate: GLSLStandardProgram())

  /// A shader type.
  public enum ShaderType {

    /// A vertex shader.
    case vertex

    /// A fragment shader.
    case fragment

    fileprivate var glValue: GL.Enum {
      switch self {
      case .vertex  : return GL.Enum(GL.VERTEX_SHADER)
      case .fragment: return GL.Enum(GL.FRAGMENT_SHADER)
      }
    }

  }

  // MARK: Internal API

  /// A handle to the program loaded in GPU memory.
  private var handle: GL.UInt = 0

  internal private(set) var state: GraphicsResourceState

  public func load() throws {
    assert(state != .gone)
    guard state != .loaded
      else { return }

    assert(AppContext.shared.isInitialized)
    assert(glfwGetCurrentContext() != nil)

    // Compile the vertex shader.
    let vertexShaderID = try compile(type: .vertex, source: delegate.vertexSource)
    assert(vertexShaderID != 0)
    defer { glDeleteShader(vertexShaderID) }

    // Compile the fragment shader.
    let fragmentShaderID = try compile(type: .fragment, source: delegate.fragmentSource)
    assert(vertexShaderID != 0)
    defer { glDeleteShader(fragmentShaderID) }

    // Create and link the program in the GPU.
    handle = try link(vertexShaderID, fragmentShaderID)
    state = .loaded
    assert(handle != 0)

    locations = [:]
  }

  public func unload() {
    if handle > 0 {
      glDeleteProgram(handle)
      handle = 0
    }

    state = .unloaded
  }

  /// Installs a program object as part of current rendering state.
  internal func install() {
    assert(glfwGetCurrentContext() != nil)
    assert(state == .loaded)
    glUseProgram(handle)
    delegate.didInstall(self)
  }

  /// Compiles a shader.
  private func compile(type: GLSLProgram.ShaderType, source: String) throws -> GL.UInt {
    let shaderID = glCreateShader(type.glValue)
    source.withCString({ cSource in glShaderSource(shaderID, 1, [cSource], nil) })
    glCompileShader(shaderID)

    var infoLogCount: Int32 = 0
    var infoLog: UnsafeMutablePointer<Int8>?
    defer { infoLog?.deallocate() }

    glGetShaderiv(shaderID, GL.INFO_LOG_LENGTH, &infoLogCount)
    if infoLogCount > 0 {
      infoLog = .allocate(capacity: Int(infoLogCount))
      glGetShaderInfoLog(shaderID, infoLogCount, nil, infoLog)
    }

    var success: GL.Int = 0
    glGetShaderiv(shaderID, GL.COMPILE_STATUS, &success)
    guard success == GL.TRUE else {
      glDeleteShader(shaderID)
      throw GLSLError.compilation(shader: type, message: String(cString: infoLog!))
    }

    if let log = infoLog {
      LogManager.main.log(
        "Shader compilation issued the following message: \(String(cString: log))",
        level: (success == GL.TRUE) ? LogLevel.warning : LogLevel.error)
    }

    return shaderID
  }

  /// Links a shader program.
  private func link(_ vertexShaderID: GL.UInt, _ fragmentShaderID: GL.UInt) throws -> GL.UInt {
    let programID = glCreateProgram()
    glAttachShader(programID, vertexShaderID)
    glAttachShader(programID, fragmentShaderID)

    // TODO: Set default attribute shader locations?

    glLinkProgram(programID)

    var infoLogCount: Int32 = 0
    var infoLog: UnsafeMutablePointer<Int8>?
    defer { infoLog?.deallocate() }

    glGetProgramiv(programID, GL.INFO_LOG_LENGTH, &infoLogCount)
    if infoLogCount > 0 {
      infoLog = .allocate(capacity: Int(infoLogCount))
      glGetProgramInfoLog(programID, infoLogCount, nil, infoLog)
    }

    var success: GL.Int = 0
    glGetProgramiv(programID, GL.LINK_STATUS, &success)
    guard success == GL.TRUE else {
      glDeleteProgram(programID)
      throw GLSLError.linking(message: String(cString: infoLog!))
    }

    if let log = infoLog {
      LogManager.main.log(
        "Shader linking issued the following message: \(String(cString: log))",
        level: (success == GL.TRUE) ? LogLevel.warning : LogLevel.error)
    }

    return programID
  }

  deinit {
    unload()
  }

}
