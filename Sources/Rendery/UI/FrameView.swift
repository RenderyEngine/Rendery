/// A frame within which a subview can be positioned.
public struct FrameView<Subview> where Subview: View {

  public init(
    _ subview: Subview,
    width: Double? = nil,
    height: Double? = nil,
    alignment: FrameViewAlignment = .center
  ) {
    self.subview = subview
    self.width = width
    self.height = height
    self.alignment = alignment
  }

  public var subview: Subview

  /// The frame's extrinsic width, if defined.
  private var width: Double?

  public func width(_ value: Double?) -> FrameView {
    var newView = self
    newView.width = value
    return newView
  }

  /// The frame's extrinsic height, if defined.
  private var height: Double?

  public func height(_ value: Double?) -> FrameView {
    var newView = self
    newView.height = value
    return newView
  }

  public var alignment: FrameViewAlignment

  public func alignment(_ value: FrameViewAlignment) -> FrameView {
    var newView = self
    newView.alignment = value
    return newView
  }

  public var padding = EdgeInsets()

  public func padding(_ value: EdgeInsets) -> FrameView {
    var newView = self
    newView.padding = value
    return newView
  }

  public func padding(_ value: Double) -> FrameView {
    var newView = self
    newView.padding = EdgeInsets(top: value, left: value, bottom: value, right: value)
    return newView
  }

  public func padding(horizontal value: Double) -> FrameView {
    var newView = self
    newView.padding.top = value
    newView.padding.bottom = value
    return newView
  }

  public func padding(vertical value: Double) -> FrameView {
    var newView = self
    newView.padding.left = value
    newView.padding.right = value
    return newView
  }

  public var background: Color = .transparent

  public func background(_ value: Color) -> FrameView {
    var newView = self
    newView.background = value
    return newView
  }

}

extension FrameView: View {

  public var dimensions: Vector2 {
    let content = subview.dimensions
    return Vector2(
      x: width ?? content.x + padding.left + padding.right,
      y: height ?? content.y + padding.top + padding.bottom)
  }

  public func render(into renderer: inout ViewRenderer) {
    if background.alpha != 0 {
      renderer.draw(rectangleOfSize: dimensions, color: background)
    }

    let currentPenPosition = renderer.penPosition
    defer { renderer.penPosition = currentPenPosition }

    // Apply the subview's vertical alignment, if possible.
    if let width = self.width {
      let contentWidth = width - (padding.left + padding.right)
      if contentWidth > subview.dimensions.x {
        switch alignment {
        case .topLeft, .left, .bottomLeft:
          break
        case .top, .center, .bottom:
          renderer.penPosition.x += (contentWidth - subview.dimensions.x) / 2.0
        case .topRight, .right, .bottomRight:
          renderer.penPosition.x += (contentWidth - subview.dimensions.x)
        }
      }
    }

    // Apply the subview's horizontal alignment, if possible.
    if let height = self.height {
      let contentHeight = height - (padding.top + padding.bottom)
      if contentHeight > subview.dimensions.y {
        switch alignment {
        case .topLeft, .top, .topRight:
          break
        case .left, .center, .right:
          renderer.penPosition.y += (contentHeight - subview.dimensions.y) / 2.0
        case .bottomLeft, .bottom, .bottomRight:
          renderer.penPosition.y += (contentHeight - subview.dimensions.y)
        }
      }
    }

    renderer.penPosition.x += padding.left
    renderer.penPosition.y += padding.top
    subview.render(into: &renderer)
  }

}
