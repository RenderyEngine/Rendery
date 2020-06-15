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

  /// Assigns a boolean at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - boolean: The boolean value to assign.
  ///   - location: The name of the variable to which the value should be assigned.
  public func assign(boolean: Bool, at location: String) {
    let locID = glGetUniformLocation(handle, location)
    glUniform1i(locID, boolean ? 1 : 0)
  }

  /// Assigns an integer at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - integer: The integer value to assign.
  ///   - location: The name of the variable to which the value should be assigned.
  public func assign(integer: Int, at location: String) {
    let locID = glGetUniformLocation(handle, location)
    glUniform1i(locID, Int32(integer))
  }

  /// Assigns a color value at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - color: The color value to assign.
  ///   - location: The name of the variable to which the value should be assigned.
  ///   - discardingAlpha: A flag that indicates whether the alpha channel should be discarded.
  public func assign(color: Color, at location: String, discardingAlpha: Bool = true) {
    let locID = glGetUniformLocation(handle, location)
    if discardingAlpha {
      glUniform3f(
        locID,
        Float(color.red) / 255.0,
        Float(color.green) / 255.0,
        Float(color.blue) / 255.0)
    } else {
      glUniform4f(
        locID,
        Float(color.red) / 255.0,
        Float(color.green) / 255.0,
        Float(color.blue) / 255.0,
        Float(color.alpha) / 255.0)
    }
  }

  /// Assigns a 2D vector at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - vector2: The vector value to assign.
  ///   - location: The name of the variable to which the value should be assigned.
  public func assign(vector2: Vector2, at location: String) {
    let locID = glGetUniformLocation(handle, location)
    glUniform2f(locID, Float(vector2.x), Float(vector2.y))
  }

  /// Assigns a 3D vector at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - vector3: The vector value to assign.
  ///   - location: The name of the variable to which the value should be assigned.
  public func assign(vector3: Vector3, at location: String) {
    let locID = glGetUniformLocation(handle, location)
    glUniform3f(locID, Float(vector3.x), Float(vector3.y), Float(vector3.z))
  }

  /// Assigns a 3x3 matrix at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - matrix3: The matrix value to assign.
  ///   - location: The name of the variable to which the value should be assigned.
  public func assign(matrix3: Matrix3, at location: String) {
    let locID = glGetUniformLocation(handle, location)
    let data = matrix3.components.map(Float.init)
    glUniformMatrix3fv(locID, 1, 1, data)
  }

  /// Assigns a 4x4 matrix at the specified location.
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - matrix4: The matrix value to assign.
  ///   - location: The name of the variable to which the value should be assigned.
  public func assign(matrix4: Matrix4, at location: String) {
    let locID = glGetUniformLocation(handle, location)
    let data = matrix4.components.map(Float.init)
    glUniformMatrix4fv(locID, 1, 1, data)
  }

  /// Assigns a texture at the specified location (or texture unit).
  ///
  /// This method is intended to be used by the program's delegate to setup its variables.
  ///
  /// - Parameters:
  ///   - color: The texture to assign.
  ///   - sampler: The name of the sampler to which the texture should be assigned.
  ///   - location: The location unit to which the texture should be assigned.
  public func assign(texture: Texture, to sampler: String, at location: Int) {
    // Make sure the texture has been loaded in GPU memory.
    texture.load()

    // Activate the texture unit.
    glActiveTexture(GL.TEXTURE0 + UInt32(location))
    glBindTexture(GL.TEXTURE_2D, texture.handle)
    assign(integer: location, at: sampler)
  }

  /// Handles the setup if the program’s parameters.
  ///
  /// - Parameter context: The program's binding context.
  internal func bind(_ context: UnsafeRawPointer) {
    delegate.bind(self, in: context)
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

  internal func load() throws {
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
    self.handle = try link(vertexShaderID, fragmentShaderID)
    self.state = .loaded
    assert(self.handle != 0)
    LogManager.main.log("GLSL program '\(handle)' successfully loaded.", level: .debug)

    // Bind the program's lifetime to the app context.
    AppContext.shared.graphicsResourceManager.store(self)
  }

  internal func unload() {
    if handle > 0 {
      glDeleteProgram(handle)
      LogManager.main.log("GLSL program '\(handle)' successfully unloaded.", level: .debug)
      handle = 0
    }

    state = .unloaded
  }

  /// Installs a program object as part of current rendering state.
  internal func install() {
    assert(glfwGetCurrentContext() != nil)
    assert(state == .loaded)
    glUseProgram(handle)
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
      throw GLSLError.compilation(shader: .vertex, message: String(cString: infoLog!))
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
    AppContext.shared.graphicsResourceManager.remove(self)
  }

}
