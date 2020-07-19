public final class FrameView {

  /// Initializes a frame view.
  ///
  /// - Parameters subview: The subview that is contained in the frame.
  public init(around subview: View) {
    self.subview = subview
    self.dimensions = subview.dimensions

    subview.container = self
  }

  public var dimensions: Vector2

  /// Updates the frame's dimensions.
  ///
  /// - Parameter dimensions: The dimensions to assign.
  public func setting(dimensions: Vector2) -> FrameView {
    self.dimensions = dimensions
    return self
  }

  /// Updates the frame's width.
  ///
  /// - Parameter width: The width to assign.
  public func setting(width: Double) -> FrameView {
    self.dimensions.x = width
    return self
  }

  /// Updates the frame's height.
  ///
  /// - Parameter height: The height to assign.
  public func setting(height: Double) -> FrameView {
    self.dimensions.y = height
    return self
  }

  public weak var container: View?

  /// The subview contained in this frame.
  public let subview: View

  /// The alignment of the contained subview.
  public var alignment: Alignment = .center

  /// Updates the frame's content alignemnt.
  ///
  /// - Parameter alignment: The content alignment to assign.
  public func setting(alignment: Alignment) -> FrameView {
    self.alignment = alignment
    return self
  }

  /// The alignment of a subview in a frame.
  public enum Alignment {

    /// The top-left edge of the frame.
    case topLeft

    /// The top edge of the frame.
    case top

    /// The top-right edge of the frame.
    case topRight

    /// The left edge of the frame.
    case left

    /// The center of the frame.
    case center

    /// The right edge of the frame.
    case right

    /// The bottom-left edge of the frame.
    case bottomLeft

    /// The bottom edge of the frame.
    case bottom

    /// The bottom-right edge of the frame.
    case bottomRight

  }

  /// The frame's background.
  public var background: Color?

  /// Updates the frame's background.
  ///
  /// - Parameter background: The background to assign.
  public func setting(background: Color?) -> FrameView {
    self.background = background
    return self
  }

}

extension FrameView: View {

  /// Computes the offset of the subview in this frame.
  private func subviewOffset() -> Vector2 {
    let subviewDimensions = subview.dimensions
    var offset: Vector2 = .zero

    if dimensions.x > subviewDimensions.x {
      switch alignment {
      case .topLeft, .left, .bottomLeft:
        break
      case .top, .center, .bottom:
        offset.x += (dimensions.x - subviewDimensions.x) / 2.0
      case .topRight, .right, .bottomRight:
        offset.x += (dimensions.x - subviewDimensions.x)
      }
    }

    if dimensions.y > subviewDimensions.y {
      switch alignment {
      case .topLeft, .top, .topRight:
        break
      case .left, .center, .right:
        offset.y += (dimensions.y - subviewDimensions.y) / 2.0
      case .bottomLeft, .bottom, .bottomRight:
        offset.y += (dimensions.y - subviewDimensions.y)
      }
    }

    return offset
  }

  public func view(at point: Vector2) -> View? {
    guard (point.x >= 0.0) && (point.x <= dimensions.x)
      else { return nil }
    guard (point.y >= 0.0) && (point.y <= dimensions.y)
      else { return nil }

    return subview.view(at: point - subviewOffset()) ?? self
  }

  public func draw<Context>(in context: inout Context) where Context: ViewDrawingContext {
    if let background = self.background {
      context.fill(rectangle: Rectangle(origin: .zero, dimensions: dimensions), color: background)
    }

    context.penPosition += subviewOffset()
    subview.draw(in: &context)
  }

}
