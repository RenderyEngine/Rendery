/// Rendery's built-in default pipeline.
public struct DefaultRenderPipeline: RenderPipeline {

  public func render(viewport: Viewport, in context: RenderContext) {
    // Make sure there's a scene to render.
    guard let scene = viewport.scene
      else { return }

    // Assign the camera's view-projection matrix.
    guard let viewProjMatrix = viewport.viewProjMatrix
      else { return }
    context.viewProjMatrix = viewProjMatrix

    // Define a function that sorts light nodes inby their distance to a specified target.
    func lightNodes(affecting target: Node) -> [Node] {
      return scene.lightNodes.sorted(by: { (a, b) -> Bool in
        let ta = a.sceneTranslation.squaredDistance(to: target.sceneTranslation)
        let tb = b.sceneTranslation.squaredDistance(to: target.sceneTranslation)
        return ta < tb
      })
    }

    // Clear the scene's background (if any).
    scene.backgroundColor.map(context.clear(color:))

    // Enable depth test.
    context.isDepthTestEnabled = true

    // Render all model nodes.
    let lightSettings = LightSettings(
      ambient: scene.ambientLight,
      lightEntities: scene.lightNodes.compactMap({ LightEntity(node: $0) }))
    context.draw(modelNodes: scene.modelNodes, lightSettings: lightSettings)
  }

}
