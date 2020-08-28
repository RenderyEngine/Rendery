/// Rendery's built-in standard shader.
///
/// This shader implements the Blinn–Phong reflection model.
public struct GLSLStandardProgram: GLSLProgramDelegate {

  public var vertexSource: String { _vertexSource }

  public var fragmentSource: String { _fragmentSource }

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
