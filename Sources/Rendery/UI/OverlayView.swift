/// A view container that overlays its subviews, allowing them to be offset along both axes.
public final class OverlayView {

  /// Initializes an overlay view with the subviews it contains.
  ///
  /// - Parameter elements: The subviews to add to this container, with their associated offset.
  public init<S>(_ elements: S) where S: Sequence, S.Element == (subview: View, offset: Vector2) {
    self.elements = Array(elements)

    for (subview, _) in self.elements {
      subview.container = self
    }
  }

  /// Initializes an empty overlay view.
  public convenience init() {
    self.init([])
  }

  public weak var container: View?

  /// The contained subviews, with their associated offset in this container's coordinate system.
  public private(set) var elements: [(subview: View, offset: Vector2)]

  /// Appends a new subview to this container.
  ///
  /// - Parameters:
  ///   - subview: The subview to add to this container.
  ///   - offset: The subview's offset in this container's coordinate system.
  public func append(_ subview: View, offsetBy offset: Vector2) {
    elements.append((subview, offset))
    subview.container = self
  }

  /// Appends a new subview to this container, and returns the updated container.
  ///
  /// - Parameters:
  ///   - subview: The subview to add to this container.
  ///   - offset: The subview's offset in this container's coordinate system.
  public func appending(_ subview: View, offsetBy offset: Vector2) -> OverlayView {
    append(subview, offsetBy: offset)
    return self
  }

  /// Removes the specified subview from this container.
  ///
  /// - Parameter subview: The subview to remove.
  public func remove(_ subview: View) {
    guard let i = elements.firstIndex(where: { (s, _) in s === subview })
      else { return }
    elements.remove(at: i)
  }

  /// Removes the specified subview from this container, and returns the updated container.
  ///
  /// - Parameter subview: The subview to remove.
  public func removing(_ subview: View) -> OverlayView {
    remove(subview)
    return self
  }

}

extension OverlayView: View {

  public var dimensions: Vector2 {
    var dimensions = Vector2.zero

    for (subview, offset) in elements {
      let subviewDimensions = subview.dimensions
      if subviewDimensions.x + offset.x > dimensions.x {
        dimensions.x = subviewDimensions.x + offset.x
      }
      if subviewDimensions.y + offset.y > dimensions.y {
        dimensions.y = subviewDimensions.y + offset.y
      }
    }

    return dimensions
  }

  public func view(at point: Vector2) -> View? {
    for (subview, offset) in elements {
      if let child = subview.view(at: point - offset) {
        return child
      }
    }

    return nil
  }

  public func draw<Context>(in context: inout Context) where Context: ViewDrawingContext {
    let initialPenPosition = context.penPosition

    for (subview, offset) in elements {
      context.penPosition = initialPenPosition + offset
      subview.draw(in: &context)
    }
  }

}
