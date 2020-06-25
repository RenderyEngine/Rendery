/// Rendery's built-in outline shader.
public struct GLSLOutlineProgram: GLSLProgramDelegate {

  public var vertexSource: String { _vertexSource }

  public var fragmentSource: String { _fragmentSource }

  public func bind(_ program: GLSLProgram, in context: UnsafeRawPointer) {
    // Extract parameters from context.
    let parameters = context.assumingMemoryBound(to: Model.OutlinePassContext.self).pointee

    program.assign(color: parameters.outlineColor, at: "outlineColor")
    program.assign(matrix4: parameters.modelViewProjectionMatrix, at: "mvp")
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

uniform vec3 outlineColor;

out vec4 finalColor;

void main() {
  finalColor = vec4(outlineColor, 1.0);
}
"""
