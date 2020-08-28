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

  /// Handles the setup if the program's parameters.
  ///
  /// This method is called before using the program to render an object to bind the attributes and
  /// uniform variables used by the shader program through its `assign` methods.
  ///
  /// The value pointed by `context` contains information about the object being rendered, which
  /// depends on the context in which the program is being initialized:
  /// - When used to draw a **mesh** (from `Model.draw(transform:node:)`), `context` is a pointer
  ///   to a `Model.DrawingContext` instance.
  func bind(_ program: GLSLProgram, in context: UnsafeRawPointer)

}

extension GLSLProgramDelegate {

  public var maxLightCount: Int { 8 }

}
