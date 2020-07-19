public final class StackView {

  public init<S>(direction: Direction, _ subviews: S) where S: Sequence, S.Element == View {
    self.direction = direction
    self.subviews = Array(subviews)

    for subview in self.subviews {
      subview.container = self
    }
  }

  public convenience init(direction: Direction) {
    self.init(direction: direction, [])
  }

  public weak var container: View?

  /// The axis along which subviews are arranged.
  public var direction: Direction

  /// Updates the stack's direction.
  ///
  /// - Parameter direction: The stack direction to assign.
  public func setting(direction: Direction) -> StackView {
    self.direction = direction
    return self
  }

  /// An axis defining how the subviews of a stack view container are arranged.
  public enum Direction {

    case horizontal

    case vertical

  }

  /// The space between each subview.
  public var spacing: Double = 0.0

  /// Updates the stack's spacing.
  ///
  /// - Parameter spacing: The spacing to assign.
  public func setting(spacing: Double) -> StackView {
    self.spacing = spacing
    return self
  }

  /// The contained subviews
  public private(set) var subviews: [View]

  /// Appends a new subview to this container.
  ///
  /// - Parameter subview: The subview to add to this container.
  public func append(_ subview: View) {
    subviews.append(subview)
    subview.container = self
  }

  /// Appends a new subview to this container, and returns the updated container.
  ///
  /// - Parameter subview: The subview to add to this container.
  public func appending(_ subview: View) -> StackView {
    append(subview)
    return self
  }

  /// Removes the specified subview from this container.
  ///
  /// - Parameter subview: The subview to remove.
  public func remove(_ subview: View) {
    guard let i = subviews.firstIndex(where: { s in s === subview })
      else { return }
    subviews.remove(at: i)
  }

  /// Removes the specified subview from this container, and returns the updated container.
  ///
  /// - Parameter subview: The subview to remove.
  public func removing(_ subview: View) -> StackView {
    remove(subview)
    return self
  }

}

extension StackView: View {

  public var dimensions: Vector2 {
    let accumulatedSpacing = spacing * Double(subviews.count - 1)

    switch direction {
    case .horizontal:
      let partialResult = Vector2(x: accumulatedSpacing, y: 0.0)
      return subviews.reduce(partialResult, { (partialResult, subview) -> Vector2 in
        let dim = subview.dimensions
        return Vector2(x: partialResult.x + dim.x, y: max(partialResult.y, dim.y))
      })

    case .vertical:
      let partialResult = Vector2(x: 0.0, y: accumulatedSpacing)
      return subviews.reduce(partialResult, { (partialResult, subview) -> Vector2 in
        let dim = subview.dimensions
        return Vector2(x: max(partialResult.x, dim.x), y: partialResult.y + dim.y)
      })
    }
  }

  public func view(at point: Vector2) -> View? {
    var offset: Vector2 = .zero

    for subview in subviews {
      if let child = subview.view(at: point - offset) {
        return child
      }

      switch direction {
      case .horizontal:
        offset.x += spacing + subview.dimensions.x
      case .vertical:
        offset.y += spacing + subview.dimensions.y
      }
    }

    return nil
  }

  public func draw<Context>(in context: inout Context) where Context: ViewDrawingContext {
    switch direction {
    case .horizontal:
      for subview in subviews {
        let position = context.penPosition
        subview.draw(in: &context)
        context.penPosition = Vector2(
          x: position.x + spacing + subview.dimensions.x,
          y: position.y)
      }

    case .vertical:
      for subview in subviews {
        let position = context.penPosition
        subview.draw(in: &context)
        context.penPosition = Vector2(
          x: position.x,
          y: position.y + spacing + subview.dimensions.y)
      }
    }
  }

}
