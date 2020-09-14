/// An object that can receive the result of rendering operations.
///
/// A render target is a sort of "canvas" onto which one can draw any kind of content.
public class RenderTarget {

  /// Initializes a render target.
  init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }

  /// The target's width, in pixels.
  ///
  /// For a window, this property relates to the width of its frame buffer and denotes the number
  /// of distinct pixels that can be displayed on the window, horizontally. On some devices, such
  /// as retina displays, it may be larger than the window's `screenWidth`.
  public internal(set) final var width: Int

  /// The target's height, in pixels.
  ///
  /// For a window, this property relates to the width of its frame buffer and denotes the number
  /// of distinct pixels that can be displayed on the window, vertically. On some devices, such as
  /// retina displays, it may be larger than the window's `screenHeight`.
  public internal(set) final var height: Int

  /// The target's viewports.
  public internal(set) final var viewports: [Viewport] = []

  /// Adds a new viewport to the target.
  ///
  /// - Parameter region: The region of the target designated by the viewport, in normalized
  ///   coordinates (i.e., expressed in values between `0` and `1`).
  @discardableResult
  public func createViewport(
    region: Rectangle = Rectangle(origin: .zero, dimensions: .unitScale)
  ) -> Viewport {
    let viewport = Viewport(target: self, region: region)
    viewports.append(viewport)
    return viewport
  }

  /// Removes the specified viewport from the target.
  ///
  /// This method has no effect if the specified viewport is not attached to the target.
  ///
  /// - Parameter viewport: The viewport to remove.
  public func removeViewport(_ viewport: Viewport) {
    viewports.removeAll(where: { $0 === viewport })
  }

  /// The target's render pipeline.
  public final var renderPipeline: RenderPipeline?

  /// Updates the target's content.
  public func update() {
    guard let pipeline = renderPipeline
      else { return }
    for viewport in viewports {
      viewport.update(through: pipeline)
    }
  }

}
