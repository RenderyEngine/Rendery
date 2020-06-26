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

extension AnyView: Hashable {

  public func hash(into hasher: inout Hasher) {
    box.hash(into: &hasher)
  }

  public static func == (lhs: AnyView, rhs: AnyView) -> Bool {
    lhs.box.isEqual(to: rhs.box)
  }

}

extension AnyView: View {

  public func render(into renderer: inout ViewRenderer) {
    box.render(into: &renderer)
  }

}

private protocol AnyViewBox {

  var base: Any { get }

  func render(into renderer: inout ViewRenderer)

  func hash(into hasher: inout Hasher)

  func isEqual(to other: AnyViewBox) -> Bool

}

private struct ConcreteViewBox<Base: View>: AnyViewBox {

  let baseView: Base

  var base: Any { baseView }

  func render(into renderer: inout ViewRenderer) {
    baseView.render(into: &renderer)
  }

  func hash(into hasher: inout Hasher) {
    baseView.hash(into: &hasher)
  }

  func isEqual(to other: AnyViewBox) -> Bool {
    if let rhs = other.base as? Base {
      return baseView == rhs
    }
    return false
  }

}
