/// A driver that orchestrates the series of operation necessary to render the contents of a scene.
///
/// A render pipeline typically consists of a sequence of render passes, each of them representing
/// a specific task that contributes to transforming the contents of a scene into the image which
/// is displayed on a viewport.
public protocol RenderPipeline {

  /// Renders the specified scene on the specified viewport.
  func render(scene: Scene, on viewport: Viewport)

}

/// An abstraction over a set of operations that contribute to rendering the contents of a scene.
///
/// There are essentially three main categories of render passes:
/// - Culling, which consists of filtering the contents of a scene.
/// - Scene rendering, which consists of drawing the renderable objects of the scene.
/// - Post-processing, which consists if applying global effect on a rendered scene.
public protocol RenderPass {

}
