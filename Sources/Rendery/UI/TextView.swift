/// A view that displays one line of text.
public final class TextView {

  public init(verbatim: String, face: FontFace? = nil) {
    self.verbatim = verbatim
    self.face = face
  }

  public weak var container: View?

  /// The view's verbatim content.
  private var verbatim: String

  /// The font face that is used to draw the view's content.
  public var face: FontFace?

  /// The color that is used to draw the view's content.
  public var color: Color = .black

  /// Updates the view's content color.
  ///
  /// - Parameter color: The content color to assign.
  public func setting(color: Color) -> TextView {
    self.color = color
    return self
  }

  /// The scale factor that is applied on the view's content when it is drawn.
  public var scale = 1.0

  /// Updates the view's content scale.
  ///
  /// - Parameter scale: The content scale to assign.
  public func setting(scale: Double) -> TextView {
    self.scale = scale
    return self
  }

}

extension TextView: View {

  public var dimensions: Vector2 {
    guard let face = face
      else { return .zero }

    return Vector2(
      x: verbatim.map({ (face.glyph(for: $0)?.advance ?? 0.0) / 64.0 }).reduce(0.0, +) * scale,
      y: face.height * scale)
  }

  public func draw<Context>(in context: inout Context) where Context: ViewDrawingContext {
    context.draw(string: verbatim, face: face, color: color, scale: scale)
  }

}
