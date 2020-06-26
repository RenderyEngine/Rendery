/// A rectangle that is layed over the 3D contents of a scene.
public protocol View: Hashable {

  /// Renders the view's contents into the specified view renderer.
  func render(into renderer: inout ViewRenderer)

}
