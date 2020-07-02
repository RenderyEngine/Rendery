/// A view container that arranges its subviews vertically.
public struct VStackView<Subview> where Subview: View {

  public init(spacing: Double = 0.0) {
    self.subviews = []
    self.spacing = spacing
  }

  public init<S>(_ subviews: S, spacing: Double = 0.0) where S: Sequence, S.Element == Subview {
    self.subviews = Array(subviews)
    self.spacing = spacing
  }

  public var subviews: [Subview]

  /// Sets the subviews contained in this stack.
  ///
  /// - Parameter value: An array of subviews.
  public func subviews(_ value: [Subview]) -> VStackView {
    var newView = self
    newView.subviews = value
    return newView
  }

  /// Appends a subview at the bottom of this stack.
  ///
  /// - Parameter newSubview: A subview.
  public func append(_ value: Subview) -> VStackView {
    var newView = self
    newView.subviews.append(value)
    return newView
  }

  /// The space between each subview.
  public var spacing: Double

  public func spacing(_ value: Double) -> VStackView {
    var newView = self
    newView.spacing = value
    return newView
  }

}

extension VStackView where Subview == AnyView {

  /// Appends a subview at the bottom of this stack.
  ///
  /// - Parameter subview: A subview.
  public func append<V>(_ value: V) -> VStackView where V: View {
    var newView = self
    newView.subviews.append(AnyView(value))
    return newView
  }

}

extension VStackView: View {

  public var dimensions: Vector2 {
    let totalSpacing = Vector2(x: 0.0, y: spacing * Double(subviews.count - 1))
    return subviews.reduce(totalSpacing, { (vec, subview) -> Vector2 in
      let d = subview.dimensions
      return Vector2(x: max(vec.x, d.x), y: vec.y + d.y)
    })
  }

  public func render(into renderer: inout ViewRenderer) {
    let currentPenPosition = renderer.penPosition
    for subview in subviews {
      subview.render(into: &renderer)
      renderer.penPosition.y += subview.dimensions.y + spacing
    }
    renderer.penPosition = currentPenPosition
  }

}
