/// Rendery's built-in default pipeline.
public final class DefaultRenderPipeline: RenderPipeline {

  /// Initializes a default render pipeline instance.
  public init() {
  }

  public func render(viewport: Viewport, in context: RenderContext) {
    // Make sure there's a scene to render.
    guard let scene = viewport.scene
      else { return }
    let frustum = viewport.frustum()!

    // Enable depth test.
    context.isDepthTestEnabled = true

    // Generate light entities.
    var lightEntities: [LightEntity] = []
    for node in scene.lightNodes {
      guard var lightEntity = LightEntity(node: node)
        else { continue }

      if lightEntity.light.isCastingShadow {
        renderShadowMap(entity: &lightEntity, frustum: frustum, scene: scene, context: context)
        // FIXME: Swap depth attachment if there are more than one shadow-casting light.
      }

      lightEntities.append(lightEntity)
    }

    context.set(renderTarget: viewport.target)

    // Compute the actual region of the render target designated by the viewport.
    let targetDimensions = Vector2(
      x: Double(viewport.target.width),
      y: Double(viewport.target.height))

    let scaledRegion = viewport.region.scaled(by: targetDimensions)
    context.set(viewportRegion: scaledRegion)
    context.set(scissorRegion: scaledRegion)
    defer {
      context.disableScissor()
    }

    // Assign the camera's view-projection matrix.
    guard let viewProjMatrix = viewport.viewProjMatrix
      else { return }
    context.viewProjMatrix = viewProjMatrix

    // Clear the scene's background (if any).
    scene.backgroundColor.map(context.clear(color:))

    // Render all model nodes.
    let lightSettings = LightSettings(ambient: scene.ambientLight, lightEntities: lightEntities)
    context.draw(modelNodes: scene.modelNodes, lightSettings: lightSettings)
  }

  private var shadowMapPool = TexturePool(size: 2048, format: .depth32F, wrapMethod: .repeat)

  private lazy var shadowPassTarget: FrameBuffer? = {
    do {
      return try FrameBuffer(
        width: 2048,
        height: 2048,
        depth: .texture(shadowMapPool.get()))
    } catch {
      LogManager.main.log(
        "Failed to initialize the render target for shadow passes: \(error)",
        level: .error)
      return nil
    }
  }()

  private lazy var shadowPassMaterial: Material? = {
    do {
      let material = Material(program: GLSLProgram(delegate: GLSLShadowMapShader()))
      try material.shader.load()
      return material
    } catch {
      LogManager.main.log(
        "Failed to initialize the shadow pass material: \(error)",
        level: .error)
      return nil
    }
  }()

  private func renderShadowMap(
    entity: inout LightEntity,
    frustum: Frustum,
    scene: Scene,
    context: RenderContext
  ) {
    guard let material = shadowPassMaterial
      else { return }
    guard let target = shadowPassTarget
      else { return }

    let scaledRegion = Rectangle(
      origin: .zero,
      dimensions: Vector2(x: Double(target.width), y: Double(target.height)))

    let vpMatrix = frustum.lightViewProjMatrix(rotation: entity.rotation)
    context.viewProjMatrix = vpMatrix
    context.set(renderTarget: target)
    context.set(viewportRegion: scaledRegion)
    context.disableScissor()
    context.clear(depth: true)
    context.draw(modelNodes: scene.modelNodes, materialOverride: material)

    entity.viewProjMatrix = vpMatrix
    entity.shadowMap = target.depth?.asTexture
  }

}
