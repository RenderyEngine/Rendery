/// A type that provides the source of a GLSL program and handles of the setup of its parameters.
///
/// - Important: Make sure your delegate does **not** retain any strong reference to its delegator.
///   Shader programs keep strong references on their delegate.
public protocol GLSLProgramDelegate {

  /// The GLSL source of the program's vertex shader
  var vertexSource: String { get }

  /// The GLSL source of the program's fragment shader.
  var fragmentSource: String { get }

  /// The maximum number of lights that are used when rendering.
  var maxLightCount: Int { get }

  /// Notifies the delegate that the program was "installed".
  ///
  /// This method can be used to assign the value of the shader program's custom uniforms, using
  /// different `assign` method overloads.
  ///
  /// - Parameter program: The delegator shader program.
  func didInstall(_ program: GLSLProgram)

}

extension GLSLProgramDelegate {

  public var maxLightCount: Int { 8 }

  public func didInstall(_ program: GLSLProgram) {
  }

}
