/// A rectangle that is layed over the 3D contents of a scene.
public protocol View {

  /// The dimensions of this view.
  var dimensions: Vector2 { get }

  /// Renders the view into the specified view renderer.
  func render(into renderer: inout ViewRenderer)

}

extension View {

  public func frame(
    width: Double? = nil,
    height: Double? = nil,
    alignment: FrameViewAlignment = .center
  ) -> FrameView<Self> {
    return FrameView(self, width: width, height: height, alignment: alignment)
  }

}
