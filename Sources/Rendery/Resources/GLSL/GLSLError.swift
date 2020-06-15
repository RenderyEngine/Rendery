/// An error linked to the compilation of a GLSL program.
public enum GLSLError: Error {

  /// A shader compilation error.
  case compilation(shader: GLSLProgram.ShaderType, message: String)

  /// A program linking error.
  case linking(message: String)

}
