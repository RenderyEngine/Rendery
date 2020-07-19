/// A drawing environment to render view elements.
public protocol ViewDrawingContext {

  /// The current position of the pen.
  var penPosition: Vector2 { get set }

  /// Paints the area contained within the specified rectangle.
  ///
  /// - Parameters:
  ///   - rectangle: A rectangle whose origin is relative to the current pen position.
  ///   - color: The fill color that is used to paint the rectangle.
  func fill(rectangle: Rectangle, color: Color)

  /// Draws a string of characters.
  ///
  /// - Parameters:
  ///   - string: A string with the characters to draw.
  ///   - face: The font face with which the characters are drawn.
  ///   - color: The color which which the characters are drawn.
  ///   - scale: A scale factor that is applied on each character.
  func draw(string: String, face: FontFace?, color: Color, scale: Double)

}
