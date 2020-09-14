public struct GLSLShadowMapShader: GLSLProgramDelegate {

  public init() {
  }

  public let vertexSource = """
  #version 330 core
  layout (location = 0) in vec3 i_position;

  uniform mat4 u_modelViewProjMatrix;

  void main() {
    gl_Position = u_modelViewProjMatrix * vec4(i_position, 1.0);
  }
  """

  public let fragmentSource = """
  #version 330 core

  void main() {}
  """

}
