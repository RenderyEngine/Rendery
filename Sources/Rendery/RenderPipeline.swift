/// A driver that orchestrates the series of operation necessary to render the contents of a scene.
///
/// A render pipeline defines the steps that Rendery should do to render a scene. It is essentially
/// a driver that interacts with Rendery's low-level graphics API to update the state of the render
/// system and issue drawing commands.
///
/// Conforming to `RenderPipeline` requires the implementation of a method `render(scene:to:in:)`.
/// This method will be called once per frame, for each viewport attached to an active window, and
/// will be responsible to perform all the tasks required to transform the contents of a scene into
/// the image that is displayed on the viewport.
public protocol RenderPipeline {

  /// Renders the specified scene to the specified viewport.
  ///
  /// This method is called once per frame, for each rendering viewport, and is responsible to
  /// perform all the tasks required to transform `scene` into an image. It does so by interacting
  /// with Rendery's low-level graphics API, through the `context` parameter.
  ///
  /// An implementation typically consists of multiple sequences of configuration steps, such as
  /// enabling/disabling capabilities on the render system, updating shader uniforms, changing
  /// render targets, etc., followed by a call to `RenderContext.draw(modelNodes:lightNodes:)`.
  ///
  /// - Parameters:
  ///   - scene: The scene to render.
  ///   - viewport: The viewport to which the scene should be rendered.
  ///   - context: An interface to Rendery's low-level graphics API.
  func render(scene: Scene, to viewport: Viewport, in context: RenderContext)

}
