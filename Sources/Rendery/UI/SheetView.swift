public struct Sheet: View {

  public init() {
  }

  public func render(into renderer: inout ViewRenderer) {
    renderer.draw(mesh: ViewRenderer.rectangle)
  }

}
