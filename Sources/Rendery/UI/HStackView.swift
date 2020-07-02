/// A view container that arranges its subviews horizontally.
public struct HStackView<Subview> where Subview: View {

  public init() {
    self.subviews = []
  }

  public init<S>(_ subviews: S) where S: Sequence, S.Element == Subview {
    self.subviews = Array(subviews)
  }

  public var subviews: [Subview]

  /// Sets the subviews contained in this stack.
  ///
  /// - Parameter value: An array of subviews.
  public func subviews(_ value: [Subview]) -> HStackView {
    var newView = self
    newView.subviews = value
    return newView
  }

  /// Appends a subview at the bottom of this stack.
  ///
  /// - Parameter newSubview: A subview.
  public func append(_ value: Subview) -> HStackView {
    var newView = self
    newView.subviews.append(value)
    return newView
  }

  /// The space between each subview.
  public var spacing: Double = 0.0

  public func spacing(_ value: Double) -> HStackView {
    var newView = self
    newView.spacing = value
    return newView
  }

}

extension HStackView where Subview == AnyView {

  /// Appends a subview at the bottom of this stack.
  ///
  /// - Parameter subview: A subview.
  public func append<V>(_ value: V) -> HStackView where V: View {
    var newView = self
    newView.subviews.append(AnyView(value))
    return newView
  }

}

extension HStackView: View {

  public var dimensions: Vector2 {
    let totalSpacing = Vector2(x: spacing * Double(subviews.count - 1), y: 0.0)
    return subviews.reduce(totalSpacing, { (vec, subview) -> Vector2 in
      let d = subview.dimensions
      return Vector2(x: vec.x + d.x, y: max(vec.y, d.y))
    })
  }

  public func render(into renderer: inout ViewRenderer) {
    let currentPenPosition = renderer.penPosition
    for subview in subviews {
      subview.render(into: &renderer)
      renderer.penPosition.x += subview.dimensions.x + spacing
    }
    renderer.penPosition = currentPenPosition
  }

}
