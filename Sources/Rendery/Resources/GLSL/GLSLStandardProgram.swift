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
    program.assign(color: parameters.ambient, at: "ambientLight")

    // Bind the positional lights' configuration.
    // FIXME: Use an array.
    if let node = parameters.lightNodes.first {
      program.assign(integer: 1, at: "light.enabled")
      program.assign(color: node.light!.color, at: "light.color")
      program.assign(vector3: node.sceneTranslation, at: "light.position")
    } else {
      program.assign(integer: 0, at: "light.enabled")
    }

    // Bind the mesh's material properties.
    program.assign(property: parameters.material.diffuse, at: "diffuseProperty")
    program.assign(property: parameters.material.multiply, at: "multiplyProperty")

    // Bind the transformation matrices.
    program.assign(matrix4: parameters.modelMatrix, at: "model")
    program.assign(matrix4: parameters.modelViewProjectionMatrix, at: "mvp")

    // FIXME: Computing the inverse of a 3x3 matrix is faster, but results in much harsher lighting
    // transitions. To be investigated...
    let normalMatrix = Matrix3(upperLeftOf: parameters.modelMatrix).inverted.transposed
    program.assign(matrix3: normalMatrix, at: "normalMatrix")
  }

}

private extension GLSLProgram {

  /// Assigns a material property at the specified location.
  func assign(property: Material.Property, at location: String) {
    switch property {
    case .color(let color):
      assign(boolean: true, at: "\(location).isColor")
      assign(color: color, at: "\(location).color", discardingAlpha: false)

    case .texture(let texture):
      assign(boolean: false, at: "\(location).isColor")
      assign(texture: texture, to: "\(location).texture", at: 0)
    }
  }

}

private let _vertexSource = """
#version 330 core
layout (location = 0) in vec3 vertexPosition;
layout (location = 1) in vec3 vertexNormal;
layout (location = 2) in vec2 vertexUVs;

uniform mat4 model;
uniform mat4 mvp;
uniform mat3 normalMatrix;

out vec3 fragmentPosition;
out vec3 fragmentNormal;
out vec2 fragmentUVs;

void main() {
  fragmentPosition = vec3(model * vec4(vertexPosition, 1.0));
  fragmentNormal = normalMatrix * vertexNormal;
  fragmentUVs = vertexUVs;

  gl_Position = mvp * vec4(vertexPosition, 1.0);
}
"""

private let _fragmentSource = """
#version 330 core
in vec3 fragmentPosition;
in vec3 fragmentNormal;
in vec2 fragmentUVs;

struct Light {
  bool enabled;
  vec3 color;
  vec3 position;
};

struct MaterialProperty {
  bool isColor;
  vec4 color;
  sampler2D texture;
};

uniform vec3 ambientLight;
uniform Light light;

uniform MaterialProperty diffuseProperty;
uniform MaterialProperty multiplyProperty;

out vec4 finalColor;

void main() {
  vec4 diffuse = diffuseProperty.isColor
    ? diffuseProperty.color
    : texture(diffuseProperty.texture, fragmentUVs);
    if (diffuse.a < 0.1) {
      discard;
    }

  vec3 normal = normalize(fragmentNormal);
  vec3 lightDirection = normalize(light.position - fragmentPosition);
  float diff = max(dot(normal, lightDirection), 0.0);
  vec3 pointLight = diff * light.color.rgb;

  vec4 texelColor = diffuse * vec4(pointLight + ambientLight, 1.0);
  if (multiplyProperty.isColor) {
    finalColor = texelColor * multiplyProperty.color;
  } else {
    finalColor = texelColor * texture(multiplyProperty.texture, fragmentUVs);
  }
}
"""
