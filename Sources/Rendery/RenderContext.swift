import CGLFW

/// An object that can be used to interact with Rendery's low level graphics API.
public struct RenderContext {

  // The ambient light.
  public var ambientLight: Color = .white

  /// The view-projection matrix.
  public var viewProjMatrix: Matrix4 = .zero

  /// A cache mapping nodes to their corresponding model-view-projection.
  public var modelViewProjMatrices: [Node: Matrix4] = [:]

  /// A cache mapping nodes to their corresponding normal transformation matrix.
  public var normalMatrices: [Node: Matrix4] = [:]

  // A flag that indicates whether depth testing is enabled.
  public var isDepthTestingEnabled: Bool {
    get { AppContext.shared.isDepthTestingEnabled }
    set { AppContext.shared.isDepthTestingEnabled = newValue }
  }

  /// Clears the color buffer of the render target.
  public func clear(color: Color) {
    glClearColor(color.linear(gamma: AppContext.shared.gamma))
    glClear(GL.COLOR_BUFFER_BIT)
  }

  /// Draws the given models.
  ///
  /// This method draws
  ///
  /// - Parameters:
  ///   - modelNodes: A sequence of nodes with an attached model.
  ///   - material: If provided, the material used to render all meshes, overriding the material
  ///     defined by their containing model. The material must be loaded.
  ///   - lightNodes: A function that accepts a node and returns a sequence with the lights that
  ///     affect its rendering.
  public mutating func draw<M>(
    modelNodes: M,
    material: Material? = nil,
    lightNodes: (Node) -> [Node]
  ) where M: Sequence, M.Element == Node {
    // If `material` was provided, install and set up the associated shader.
    if let m = material {
      m.shader.install()
      m.shader.assign(color: ambientLight, at: "u_ambientLight")
    }

    // Iterate over the given list of renderable nodes to render their attached model.
    for node in modelNodes {
      let model = node.model!

      // Iterate over all the meshes that defined the node's model.
      for (offset, mesh) in node.model!.meshes.enumerated() {
        // Makes sure the mesh is loaded.
        mesh.load()

        // Determine the mesh's material.
        let m: Material
        if let m_ = material {
          m = m_
        } else {
          if model.materials.isEmpty {
            m = Material(program: .default)
          } else {
            m = model.meshes.count <= model.materials.count
              ? model.materials[offset]
              : model.materials[offset % model.materials.count]
          }

          // Install and set up the material shader.
          try! m.shader.load()
          m.shader.install()
          m.shader.assign(color: ambientLight, at: "u_ambientLight")
        }

        // Compute the transformation matrices.
        var modelMatrix = node.sceneTransform
        if model.pivotPoint != Vector3(x: 0.5, y: 0.5, z: 0.5) {
          let bb = model.aabb
          let translation = (Vector3.unitScale - model.pivotPoint) * bb.dimensions + bb.origin
          modelMatrix = modelMatrix * Matrix4(translation: translation)
        }

        let modelViewProjMatrix: Matrix4
        if let mvp = modelViewProjMatrices[node] {
          modelViewProjMatrix = mvp
        } else {
          modelViewProjMatrix = viewProjMatrix * modelMatrix
          modelViewProjMatrices[node] = modelViewProjMatrix
        }

        // Set up "per-drawable" shader uniforms.
        m.shader.assign(matrix4: modelMatrix, at: "u_modelMatrix")
        m.shader.assign(matrix4: modelViewProjMatrix, at: "u_modelViewProjMatrix")
        m.shader.assign(
          matrix3: Matrix3(upperLeftOf: modelMatrix).inverted.transposed,
          at: "u_normalMatrix")

        m.diffuse.assign(to: "u_diffuse", textureUnit: 0, in: m.shader)
        m.multiply.assign(to: "u_multiply", textureUnit: 1, in: m.shader)

        var i = 0
        for lightNode in lightNodes(node).prefix(m.shader.maxLightCount) {
          // FIXME: Handle different the lighting type.
          guard lightNode.light?.lightingType == .point
            else { continue }

          let prefix = "u_pointLights[\(i)]"
          m.shader.assign(color: lightNode.light!.color, at: prefix + ".color")
          m.shader.assign(vector3: lightNode.sceneTranslation, at: prefix + ".position")
          i += 1
        }
        m.shader.assign(integer: i, at: "u_pointLightCount")

        // Draw the mesh.
        mesh.draw()
      }
    }
  }

}
