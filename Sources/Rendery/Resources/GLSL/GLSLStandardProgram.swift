/// Rendery's built-in standard shader.
///
/// This shader implements the Blinn–Phong reflection model.
public struct GLSLStandardProgram: GLSLProgramDelegate {

  public var vertexSource: String { _vertexSource }

  public var fragmentSource: String { _fragmentSource }

  public func bind(_ program: GLSLProgram, in context: UnsafeRawPointer) {
    // Extract parameters from context.
    let parameters = context.assumingMemoryBound(to: Model.ColorPassContext.self).pointee

    // Bind the scene's ambient light.
    program.assign(color: parameters.ambient, at: "u_ambientLight")

    // Bind the positional lights' configuration.
    // FIXME: Use an array.
    if let node = parameters.lighteners.first {
      program.assign(integer: 1, at: "lights[0].enabled")
      program.assign(color: node.light!.color, at: "lights[0].color")
      program.assign(vector3: node.sceneTranslation, at: "lights[0].position")
    } else {
      program.assign(integer: 0, at: "lights[0].enabled")
    }

    // Bind the mesh's material properties.
    parameters.material.diffuse.assign(to: "material.diffuse", textureUnit: 0, in: program)
    parameters.material.multiply.assign(to: "material.multiply", textureUnit: 1, in: program)

    // Bind the transformation matrices.
    program.assign(matrix4: parameters.modelMatrix, at: "model")
    program.assign(matrix4: parameters.modelViewProjectionMatrix, at: "mvp")

    let normalMatrix = Matrix3(upperLeftOf: parameters.modelMatrix).inverted.transposed
    program.assign(matrix3: normalMatrix, at: "normalMatrix")
  }

}

private let _vertexSource = """
#version 330 core
layout (location = 0) in vec3 i_position;
layout (location = 1) in vec3 i_normal;
layout (location = 2) in vec2 i_texcoords;

uniform mat4 u_modelMatrix;
uniform mat4 u_modelViewProjMatrix;
uniform mat3 u_normalMatrix;

out VertexData {
  vec3 position;
  vec3 normal;
  vec2 texcoords;
} o;

void main() {
  o.position = vec3(u_modelMatrix * vec4(i_position, 1.0));
  o.normal = u_normalMatrix * i_normal;
  o.texcoords = i_texcoords;

  gl_Position = u_modelViewProjMatrix * vec4(i_position, 1.0);
}
"""

private let _fragmentSource = """
#version 330 core
in VertexData {
  vec3 position;
  vec3 normal;
  vec2 texcoords;
} i;

struct Light {
  bool enabled;
  vec3 color;
  vec3 position;
};

uniform vec3 u_ambientLight;
uniform Light u_pointLights[1];
uniform int u_pointLightCount;

struct MaterialProperty {
  vec4 color;
  sampler2D texture;
};

uniform MaterialProperty u_diffuse;
uniform MaterialProperty u_multiply;

out vec4 finalColor;

void main() {
  // Compute the contribution of each material property.
  vec4 diffuseColor = u_diffuse.color * texture(u_diffuse.texture, i.texcoords);
  if (diffuseColor.a < 0.1) {
    discard;
  }

  vec4 multiplyColor = u_multiply.color * texture(u_multiply.texture, i.texcoords);

  // Compute lighting.
  vec3 lightColor = vec3(0.0, 0.0, 0.0);

  for (int index = 0; index < u_pointLightCount; ++index) {
    vec3 direction = normalize(u_pointLights[index].position - i.position);
    float diff = max(dot(i.normal, direction), 0.0);
    lightColor = lightColor + diff * u_pointLights[index].color;
  }

  lightColor = lightColor + u_ambientLight;

  // Compute the final color.
  finalColor = diffuseColor * multiplyColor * vec4(lightColor, 1.0);
}
"""
