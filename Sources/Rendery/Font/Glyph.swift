/// A typographic symbol rasterized into a texture.
public struct Glyph {

  /// The texture representing the glyph.
  public let texture: Texture?

  /// The glyph's size.
  public let size: Vector2

  /// The offset from glyph's baseline to its top-left corner.
  public let bearing: Vector2

  /// The offset to advance to next glyph.
  public let advance: Double

}
