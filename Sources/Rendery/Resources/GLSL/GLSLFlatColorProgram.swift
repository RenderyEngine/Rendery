/// Rendery's built-in flat color shader.
public struct GLSLFlatColorProgram: GLSLProgramDelegate {

  public typealias Parameters = (color: Color, mvp: Matrix4)

  public var vertexSource: String { _vertexSource }

  public var fragmentSource: String { _fragmentSource }

  public func bind(_ program: GLSLProgram, in context: UnsafeRawPointer) {
    // Extract parameters from context.
    let parameters = context.assumingMemoryBound(to: Parameters.self).pointee

    program.assign(color: parameters.color, at: "color")
    program.assign(matrix4: parameters.mvp, at: "mvp")
  }

}

private let _vertexSource = """
#version 330 core
layout (location = 0) in vec3 vertexPosition;

uniform mat4 mvp;

void main() {
  gl_Position = mvp * vec4(vertexPosition, 1.0);
}
"""

private let _fragmentSource = """
#version 330 core
uniform vec3 color;

out vec4 finalColor;

void main() {
  finalColor = vec4(color, 1.0);
}
"""
