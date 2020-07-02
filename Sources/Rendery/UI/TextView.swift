/// A view that displays one line of text.
public struct TextView {

  public init(verbatim content: String, face: FontFace? = nil) {
    self._content = content
    self.face = face
  }

  private var _content: String

  public var face: FontFace?

  public var color: Color = .black

  public func color(_ value: Color) -> TextView {
    var newView = self
    newView.color = value
    return newView
  }

  public var scale = 1.0

  public func scale(_ value: Double) -> TextView {
    var newView = self
    newView.scale = value
    return newView
  }

}

extension TextView: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_content)
    hasher.combine(color)
    if let face = face {
      hasher.combine(ObjectIdentifier(face))
    }
  }

  public static func == (lhs: TextView, rhs: TextView) -> Bool {
    return lhs._content == rhs._content
        && lhs.face === rhs.face
        && lhs.color == rhs.color
  }

}

extension TextView: View {

  public var dimensions: Vector2 {
    guard let face = face
      else { return .zero }

    return Vector2(
      x: _content.map({ (face.glyph(for: $0)?.advance ?? 0.0) / 64.0 }).reduce(0.0, +) * scale,
      y: face.height * scale)
  }

  public func render(into renderer: inout ViewRenderer) {
    renderer.draw(string: _content, face: face, color: color, scale: scale)
  }

}
