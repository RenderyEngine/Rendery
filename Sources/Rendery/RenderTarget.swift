/// An object that can receive the result of rendering operations.
///
/// A render target is a sort of "canvas" onto which one can draw any kind of content.
public protocol RenderTarget {

  /// The target's width, in pixels.
  var width: Int { get }

  /// The target's height, in pixels.
  var height: Int { get }

  /// The target's viewports.
  var viewports: [Viewport] { get }

  /// The target's render pipeline.
  var renderPipeline: RenderPipeline { get set }

  /// Updates the target's content.
  func update()

}
