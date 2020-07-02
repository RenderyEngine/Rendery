public struct EmptyView {

  public init() {
  }

}

extension EmptyView: View {

  public var dimensions: Vector2 { .zero }

  public func render(into renderer: inout ViewRenderer) {
  }


}
