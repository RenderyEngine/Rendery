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
      return scene.lightNodes.sorted(by: { (a, b) -> Bool in
        let ta = a.sceneTranslation.squaredDistance(to: target.sceneTranslation)
        let tb = b.sceneTranslation.squaredDistance(to: target.sceneTranslation)
        return ta < tb
      })
    }

    // Clear the scene's background.
    scene.backgroundColor.map(context.clear(color:))

    // Render all model nodes.
    context.draw(modelNodes: scene.modelNodes, lightNodes: lightNodes)
  }

}
