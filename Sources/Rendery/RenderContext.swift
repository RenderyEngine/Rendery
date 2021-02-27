import GL
import CGLFW
import CGlad

/// An object that can be used to interact with Rendery's low level graphics API.
public final class RenderContext {

  // MARK: Render state

  /// Reinitializes a render context to its default settings.
  internal func reset() {
    // Enable blending and specifies how OpenGL should handle transparency.
    isBlendingEnabled = true
    isAlphaPremultiplied = true

    // Enable back face culling.
    culling = .back

    // Enable depth test.
    isDepthTestEnabled = true

    // Disable stencil test.
    stencil.isEnabled = false
    stencil.setWriteMask(0xff)
    stencil.setFunction(.always(reference: 0, mask: 0xff))
    stencil.setActions(
      onStencilFailure: .keep,
      onStencilSuccessAndDepthFailure: .keep,
      onStencilAndDepthSuccess: .keep)

    // Configure OpenGL so that it performs gamma correction when writing to a sRGB target.
    glEnable(Int32(GL.FRAMEBUFFER_SRGB))
  }

  /// The generation number of the next frame to render.
  ///
  /// This number uniquely identifies a frame and can be used to invalidate cache between two
  /// render cycles.
  public internal(set) var generation: UInt64 = 0

  /// A flag that indicates whether transparent textures have their alpha-channel premultiplied.
  public var isAlphaPremultiplied = true {
    didSet {
      if isAlphaPremultiplied {
        glBlendFunc(Int32(GL.ONE), Int32(GL.ONE_MINUS_SRC_ALPHA))
      } else {
        glBlendFunc(Int32(GL.SRC_ALPHA), Int32(GL.ONE_MINUS_SRC_ALPHA))
      }
    }
  }

  /// A flag that indicates whether blending is enabled.
  public var isBlendingEnabled = true {
    didSet { glToggle(capability: GL.BLEND, isEnabled: isBlendingEnabled) }
  }

  /// The culling mode of the render system.
  public var culling = CullingMode.back {
    didSet {
      switch culling {
      case .none:
        glDisable(Int32(GL.CULL_FACE))

      case .front:
        glEnable(Int32(GL.CULL_FACE))
        glCullFace(Int32(GL.FRONT))

      case .back:
        glEnable(Int32(GL.CULL_FACE))
        glCullFace(Int32(GL.BACK))

      case .both:
        glEnable(Int32(GL.CULL_FACE))
        glCullFace(Int32(GL.FRONT_AND_BACK))
      }
    }
  }

  /// A face culling mode.
  public enum CullingMode {

    /// No culling is applied.
    case none

    /// Culling is applied on front faces.
    case front

    /// Culling is applied on back faces.
    case back

    /// Culling is applied on both front and back faces.
    case both

  }

  // A flag that indicates whether depth testing is enabled.
  public var isDepthTestEnabled = true {
    didSet { glToggle(capability: GL.DEPTH_TEST, isEnabled: isDepthTestEnabled) }
  }

  /// The stencil state of the render system.
  public var stencil = StencilState()

  // MARK: Scene properties

  /// The view-projection matrix of the scene's point of view.
  public var viewProjMatrix: Matrix4 = .zero {
    didSet { modelViewProjMatrices.removeAll(keepingCapacity: true) }
  }

  /// A cache mapping nodes to their corresponding model matrix.
  internal var modelMatrices: [Node: Matrix4] = [:]

  /// A cache mapping nodes to their corresponding model-view-projection.
  internal var modelViewProjMatrices: [Node: Matrix4] = [:]

  /// A cache mapping nodes to their corresponding normal transformation matrix.
  internal var normalMatrices: [Node: Matrix3] = [:]

  // MARK: Graphics commands

  /// Clears the render target's buffers.
  ///
  /// - Parameters:
  ///   - color: The color to clear the render target, in the linear RGB color space. The color
  ///     buffer is not cleared if the parameter is set to `nil`.
  ///   - depth: Indicates whether the depth buffer should be cleared.
  ///   - stencil: Indicates whether the stencil buffer should be cleared.
  public func clear(color: Color? = nil, depth: Bool = false, stencil: Bool = false) {
    var bits: GL.BitField = 0
    if let rgb = color {
      glClearColor(rgb)
      bits = GL.COLOR_BUFFER_BIT
    }

    if depth {
      bits |= GL.DEPTH_BUFFER_BIT
    }

    if stencil {
      glStencilMask(0xff)
      bits |= GL.STENCIL_BUFFER_BIT
    }

    // Clear the screen buffers. Note that default values have to be explicitly reset for `glClear`
    // to have an effect (see https://stackoverflow.com/questions/58640953).
    glClear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT)
  }

  /// Clears the render target's color buffer.
  ///
  /// - Parameter color: The color with which the render target should be cleared.
  public func clear(color: Color) {
    glClearColor(color.linear(gamma: AppContext.shared.gamma))
    glClear(GL.COLOR_BUFFER_BIT)
  }

  /// Sets the rendering viewport.
  ///
  /// - Parameter region: The viewport's region, in pixels.
  public func set(viewportRegion region: Rectangle) {
    glViewport(region: region)
  }

  /// Enables the scissor test for the specified region.
  ///
  /// - Parameter region: The region of the scissor test, in pixels.
  public func set(scissorRegion region: Rectangle) {
    glScissor(region: region)
    glEnable(Int32(GL.SCISSOR_TEST))
  }

  /// Disables the scissor test-
  public func disableScissor() {
    glDisable(Int32(GL.SCISSOR_TEST))
  }

  /// Sets the target of subsequent rendering operations.
  public func set(renderTarget target: RenderTarget) {
    switch target {
    case let window as Window:
      set(renderTarget: window)
    case let buffer as FrameBuffer:
      set(renderTarget: buffer)
    default:
      LogManager.main.log(
        "Cannot set render target instance of type '\(type(of: target))'.",
        level: .error)
    }
  }

  /// Sets the target of subsequent rendering operations.
  ///
  /// - Parameter window: The target of subsequent rendering operations.
  public func set(renderTarget window: Window) {
    guard window.handle == glfwGetCurrentContext() else {
      LogManager.main.log("Cannot set render target to a different context.", level: .error)
      return
    }

    glBindFramebuffer(Int32(GL.FRAMEBUFFER), 0)
  }

  /// Sets the target of subsequent rendering operations.
  ///
  /// - Parameter frameBuffer: The target of subsequent rendering operations.
  public func set(renderTarget frameBuffer: FrameBuffer) {
    glBindFramebuffer(Int32(GL.FRAMEBUFFER), frameBuffer.fbo)
  }

  /// Draws the meshes composing the model of each node in the specified node list.
  ///
  /// Be sure to properly configure the context's scene settings before colling this method, as it
  /// relies on the latter to assign the ambient light and the projection matrices in each material
  /// shader program.
  ///
  /// - Parameters:
  ///   - modelNodes: A sequence of nodes with an attached model.
  ///   - lightSettings: A set of settings describing how to lit the models.
  ///   - materialOverride: If provided, the material used to render all meshes, overriding the
  ///     material defined by their associated model. The material must be loaded.
  public func draw<M>(
    modelNodes: M,
    lightSettings: LightSettings? = nil,
    materialOverride: Material? = nil
  ) where M: Sequence, M.Element == Node {
    for node in modelNodes {
      let model = node.model!

      // Compute the node's model transformation matrix.
      let modelMatrix = modelMatrices.value(forKey: node, caching: {
        var m = node.sceneTransform
        if model.pivotPoint != Vector3(x: 0.5, y: 0.5, z: 0.5) {
          let bb = model.aabb
          let translation = (Vector3.unitScale - model.pivotPoint) * bb.dimensions + bb.origin
          m = m * Matrix4(translation: translation)
        }
        return m
      })

      // Compute the node's normal matrix.
      let normalMatrix = normalMatrices.value(
        forKey: node,
        caching: Matrix3(upperLeftOf: modelMatrix).inverted.transposed)

      // Compute the node's model-view-transformation matrix.
      let modelViewProjMatrix = modelViewProjMatrices.value(
        forKey: node,
        caching: viewProjMatrix * node.sceneTransform)

      // Iterate over all the model's meshes.
      for (offset, mesh) in model.meshes.enumerated() {
        // Makes sure the mesh is loaded.
        mesh.load()

        // Determine the mesh's material.
        let m: Material
        if let m_ = materialOverride {
          m = m_
        } else if model.materials.isEmpty {
          m = Material(program: .default)
        } else {
          m = model.meshes.count <= model.materials.count
            ? model.materials[offset]
            : model.materials[offset % model.materials.count]
        }

        // Install and set up the material shader.
        try! m.shader.load()
        m.shader.install()
        m.shader.assign(lightSettings?.ambient ?? Color.black, to: "u_ambientLight")

        // Set up "per-drawable" shader uniforms.
        m.shader.assign(modelMatrix, to: "u_modelMatrix")
        m.shader.assign(normalMatrix, to: "u_normalMatrix")
        m.shader.assign(modelViewProjMatrix, to: "u_modelViewProjMatrix")
        m.shader.assign(m, to: "u_material", firstTextureUnit: 0)

        var pointLightCount = 0
        var directionalLightCount = 0

        if let settings = lightSettings {
          for entity in settings.lightEntities {
            switch entity.light.lightingType {
            case .point:
              let prefix = "u_pointLights[\(pointLightCount)]"
              m.shader.assign(entity.light.color, to: prefix + ".color")
              m.shader.assign(entity.translation, to: prefix + ".position")

              pointLightCount += 1

            case .directional:
              let prefix = "u_directionalLights[\(pointLightCount)]"
              m.shader.assign(entity.light.color, to: prefix + ".color")
              m.shader.assign(entity.rotation * -Vector3.unitZ, to: prefix + ".direction")
              m.shader.assign(entity.light.isCastingShadow, to: prefix + ".isCastingShadow")

              if entity.light.isCastingShadow,
                 let texture = entity.shadowMap,
                 let viewProjMatrix = entity.viewProjMatrix
              {
                m.shader.assign(
                  texture,
                  to: prefix + ".shadowMap",
                  textureUnit: 8 + directionalLightCount)
                m.shader.assign(viewProjMatrix, to: prefix + ".viewProjMatrix")
              }

              directionalLightCount += 1

            case .spot:
              // FIXME
              break
            }
          }
        }

        m.shader.assign(pointLightCount, to: "u_pointLightCount")
        m.shader.assign(directionalLightCount, to: "u_directionalLightCount")

        // Draw the mesh.
        mesh.draw()
      }
    }
  }

}
