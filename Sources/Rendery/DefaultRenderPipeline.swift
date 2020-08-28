import CGLFW

/// Rendery's built-in default pipeline.
public struct DefaultRenderPipeline: RenderPipeline {

  public func render(scene: Scene, to viewport: Viewport, in context: inout RenderContext) {
    // Compute the view-projection matrix.
    guard let viewProjMatrix = viewport.viewProjMatrix
      else { return }

    // Assign some global properties.
    context.ambientLight = scene.ambientLight
    context.viewProjMatrix = viewProjMatrix

    // Define a function that sorts light nodes inby their distance to a specified target.
    func lightNodes(affecting target: Node) -> [Node] {
      return scene.lighteners.sorted(by: { (a, b) -> Bool in
        let ta = a.sceneTranslation.squaredDistance(to: target.sceneTranslation)
        let tb = b.sceneTranslation.squaredDistance(to: target.sceneTranslation)
        return ta < tb
      })
    }

    // Clear the scene's background.
    scene.backgroundColor.map(context.clear(color:))

    // Enable depth testing.
    context.isDepthTestingEnabled = true
    glStencilMask(0)

    // Render all model nodes.
    context.draw(modelNodes: scene.renderable, lightNodes: lightNodes)
  }

  public func render(scene: Scene, on viewport: Viewport) {
    // Clear the scene's background.
    if let color = scene.backgroundColor {
      glClearColor(color)
      glClear(GL.COLOR_BUFFER_BIT)
    }

    // Draw the scene tree.
    AppContext.shared.isDepthTestingEnabled = true

    // Compute the view-projection matrix. This may "fail" if the viewport has no camera.
    if let viewProjectionMatrix = viewport.viewProjMatrix {
      // Compute the model-view-matrix for each object.
      var mvpMatrices: [Node: Matrix4] = [:]
      mvpMatrices.reserveCapacity(scene.renderable.count)

      for node in scene.renderable {
        let model = node.model!

        // Compute the model's transformation matrix.
        var modelMatrix = node.sceneTransform
        if model.pivotPoint != Vector3(x: 0.5, y: 0.5, z: 0.5) {
          let bb = model.aabb
          let translation = (Vector3.unitScale - model.pivotPoint) * bb.dimensions + bb.origin
          modelMatrix = modelMatrix * Matrix4(translation: translation)
        }

        // Compute the model-view-projection matrix.
        let modelViewProjectionMatrix = viewProjectionMatrix * modelMatrix

        // Cache the matrices for subsequent render passes.
        mvpMatrices[node] = modelViewProjectionMatrix
      }

      // TODO: Culling should be performed here to avoid unnecessary draw calls.
      // TODO: Z-ordering should be performed here if needed (e.g. for 2D).

      // Render the color pass (a.k.a. the beauty pass).
      colorPass(scene: scene, mvpMatrices: &mvpMatrices)

      // Render the outline pass.
      outlinePass(scene: scene, mvpMatrices: &mvpMatrices)
    }
  }

  private func colorPass(scene: Scene, mvpMatrices: inout [Node: Matrix4]) {
    for node in scene.renderable {
      let model = node.model!

      // Write the mesh's fragement to the stencil buffer if the model is outlined so that they are
      // not overridden during the object outlining pass.
      if model.isOutlined {
        glStencilMask(0xff)
        glStencilFunc(GL.ALWAYS, 1, 0xff)
      } else {
        glStencilMask(0)
      }

      for (offset, mesh) in model.meshes.enumerated() {
        // Makes sure the mesh is loaded.
        mesh.load()

        // Determine the mesh's material.
        var material: Material
        if model.materials.isEmpty {
          material = Material(program: .default)
        } else {
          material = model.meshes.count <= model.materials.count
            ? model.materials[offset]
            : model.materials[offset % model.materials.count]
        }

        // Makes sure the material's shader program is loaded.
        do {
          try material.shader.load()
        } catch {
          // Fallback on the default material.
          LogManager.main.log(error, level: .error)
          material = Material(program: .default)
        }

        // Install the shader program.
        material.shader.install()
        let context = Model.ColorPassContext(
          material: material,
          ambient: scene.ambientLight,
          lighteners: Array(scene.lighteners),
          modelMatrix: node.sceneTransform,
          modelViewProjectionMatrix: mvpMatrices[node]!)
        withUnsafePointer(to: context, { ptr in material.shader.bind(UnsafeRawPointer(ptr)) })

        // Draw the mesh.
        mesh.draw()
      }
    }
  }

  private func outlinePass(scene: Scene, mvpMatrices: inout [Node: Matrix4]) {
    let outlined = scene.renderable.filter({ node in node.model!.isOutlined })
    if !outlined.isEmpty {
      // Disable depth testing so that outlines are drawn on top of everything.
      let wasDepthTestingEnabled = AppContext.shared.isDepthTestingEnabled
      AppContext.shared.isDepthTestingEnabled = false

      // Setup the stencil testing.
      glStencilFunc(GL.NOTEQUAL, 1, 0xff)
      glStencilMask(0)

      let shader = GLSLProgram.flat
      try! shader.load()
      shader.install()

      let scaleMatrix = Matrix4(scale: Vector3.unitScale * 1.1)
      for node in outlined {
        let context: GLSLFlatColorProgram.Parameters = (
          color: node.model!.outlineColor,
          mvp: mvpMatrices[node]! * scaleMatrix)
        withUnsafePointer(to: context, { ptr in shader.bind(UnsafeRawPointer(ptr)) })

        for mesh in node.model!.meshes {
          mesh.draw()
        }
      }

      glStencilMask(0xff)
      glStencilFunc(GL.ALWAYS, 1, 0xff)

      // Restore depth testing.
      AppContext.shared.isDepthTestingEnabled = wasDepthTestingEnabled
    }
  }

}
