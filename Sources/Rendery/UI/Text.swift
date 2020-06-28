/// A view that displays one line of text.
public struct Text: View {

  public init(verbatim content: String, face: FontFace? = nil) {
    self._content = content
    self._face = face
  }

  private var _content: String

  private var _face: FontFace?

  private var _color: Color = .black

  public func color(_ color: Color) -> Text {
    var newText = self
    newText._color = color
    return newText
  }

  public func render(into renderer: inout ViewRenderer) {
    renderer.draw(string: _content, face: _face, color: _color)
  }

}

extension Text: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_content)
    hasher.combine(_color)
    if let face = _face {
      hasher.combine(ObjectIdentifier(face))
    }
  }

  public static func == (lhs: Text, rhs: Text) -> Bool {
    return lhs._content == rhs._content
        && lhs._face === rhs._face
        && lhs._color == rhs._color
  }

}
