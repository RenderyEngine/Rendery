/// A type-erased view.
public struct AnyView {

  public init<V>(_ view: V) where V: View {
    self.box = ConcreteViewBox(baseView: view)
  }

  private let box: AnyViewBox

  /// The view wrapped by this instance.
  public var base: Any {
    return box.base
  }

}

extension AnyView: View {

  public var dimensions: Vector2 { box.dimensions }

  public func render(into renderer: inout ViewRenderer) {
    box.render(into: &renderer)
  }

}

private protocol AnyViewBox {

  var base: Any { get }

  var dimensions: Vector2 { get }

  func render(into renderer: inout ViewRenderer)

}

private struct ConcreteViewBox<Base: View>: AnyViewBox {

  let baseView: Base

  var base: Any { baseView }

  var dimensions: Vector2 { baseView.dimensions }

  func render(into renderer: inout ViewRenderer) {
    baseView.render(into: &renderer)
  }

}
