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

}

extension GLSLProgramDelegate {

  public var maxLightCount: Int { 8 }

}
