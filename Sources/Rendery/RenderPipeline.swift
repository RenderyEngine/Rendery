/// A driver that orchestrates the series of operation necessary to render a viewport.
///
/// A render pipeline defines the steps that Rendery should render graphics contents. It is
/// essentially a driver that interacts with Rendery's low-level graphics API to update the state
/// of the render system and issue drawing commands.
///
/// Conforming to `RenderPipeline` requires the implementation of a method `render(viewport:in:)`.
/// This method is called once per frame, for each viewport attached to the application's output
/// render targets (typically, windows), and is responsible to perform all the tasks required to
/// transform the viewport's contents into the image.
public protocol RenderPipeline {

  /// Renders the contents of the specified viewport.
  ///
  /// This method is called once per frame, for each viewport attached to an output render target,
  /// and is responsible to perform all the tasks required to transform the viewport's content into
  /// an image. It does so by interacting with Rendery's low-level graphics API.
  ///
  /// An implementation typically consists of multiple sequences of configuration steps, such as
  /// enabling/disabling capabilities on the render system, updating shader uniforms, changing
  /// render targets, etc., followed by a call to `RenderContext.draw(modelNodes:lightNodes:)`.
  ///
  /// - Parameters:
  ///   - viewport: The viewport to render.
  ///   - context: An object acting as an interface to Rendery's low-level graphics API.
  func render(viewport: Viewport, in context: RenderContext)

}
