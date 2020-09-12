/// Rendery's built-in standard shader.
///
/// This shader implements the Blinn–Phong reflection model.
public struct GLSLStandardProgram: GLSLProgramDelegate {

  public var vertexSource: String { _vertexSource }

  public var fragmentSource: String { _fragmentSource }

}

private let maxLightCount = 3

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

struct PointLight {
  vec3 color;
  vec3 position;
};

struct DirectionalLight {
  vec3      color;
  vec3      direction;
  sampler2D shadowMap;
  mat4      viewProjMatrix;
  bool      isCastingShadow;
};

struct Material {
  vec4      diffuseColor;
  sampler2D diffuseTexture;
  vec4      multiplyColor;
  sampler2D multiplyTexture;
};

uniform vec3              u_ambientLight;
uniform PointLight        u_pointLights[\(maxLightCount)];
uniform int               u_pointLightCount;
uniform DirectionalLight  u_directionalLights[\(maxLightCount)];
uniform int               u_directionalLightCount;
uniform Material          u_material;

out vec4 finalColor;

float shadowFactor(mat4 lightViewProjMatrix, sampler2D shadowMap, vec3 fPosition) {
  // Apply perspective divide (only usefull for perspective projections).
  vec4 fLightSpacePosition = lightViewProjMatrix * vec4(fPosition, 1.0);
  vec3 coords = fLightSpacePosition.xyz / fLightSpacePosition.w;

  // Sample the shadow map.
  coords = coords * 0.5 + 0.5;
  float closestDepth = texture(shadowMap, coords.xy).r;
  float currentDepth = coords.z;

  float bias = 0.002;
  // bias = max(0.05 * (1.0 - dot(normal, lightDir)), 0.002);
  float shadow = 0.0;

  vec2 texelSize = 1.0 / textureSize(shadowMap, 0);
  for(int x = -1; x <= 1; ++x) {
    for(int y = -1; y <= 1; ++y) {
      float pcfDepth = texture(shadowMap, coords.xy + vec2(x, y) * texelSize).r;
      shadow += (currentDepth - bias) > pcfDepth ? 1.0 : 0.0;
    }
  }
  shadow /= 9.0;

  return (coords.z > 1.0) ? 0.0 : shadow;
}

vec3 applyDirectionalLight(
  DirectionalLight light,
  vec3 fNormal,
  vec3 fDiffuse
) {
  vec3 direction = normalize(-light.direction);
  float diffuseFactor = max(dot(fNormal, direction), 0.0);

  if (light.isCastingShadow) {
    float shadow = shadowFactor(light.viewProjMatrix, light.shadowMap, i.position);
    return (1.0 - shadow) * diffuseFactor * fDiffuse;
  } else {
    return diffuseFactor * fDiffuse;
  }
}

vec3 applyPointLight(PointLight light, vec3 fNormal, vec3 fPosition, vec3 fDiffuse) {
  vec3 direction = normalize(light.position - fPosition);
  float diffuseFactor = max(dot(fNormal, direction), 0.0);

  return diffuseFactor * fDiffuse;
}

void main() {
  // Extract the fragment's diffuse color from the material's `diffuse` map.
  vec4 fDiffuse = u_material.diffuseColor * texture(u_material.diffuseTexture, i.texcoords);
  if (fDiffuse.a < 0.1) {
    discard;
  }

  // Add light contributions.
  finalColor = vec4(fDiffuse.rgb * u_ambientLight, fDiffuse.a);

  for (int index = 0; index < u_directionalLightCount; ++index) {
    finalColor.rgb += applyDirectionalLight(
      u_directionalLights[index],
      i.normal,
      finalColor.rgb);
  }

  for (int index = 0; index < u_pointLightCount; ++index) {
    finalColor.rgb += applyPointLight(
      u_pointLights[index],
      i.normal,
      i.position,
      finalColor.rgb);
  }

  // Multiply the color by the material's `multiply` map.
  finalColor *= u_material.multiplyColor * texture(u_material.multiplyTexture, i.texcoords);
}
"""
