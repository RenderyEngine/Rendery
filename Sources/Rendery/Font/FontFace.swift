import CFreeType
import Foundation

/// A typographic face object.
public class FontFace {

  internal init(face: FT_Face?) {
    self.face = face
  }

  public func glyph(for character: Character) -> Glyph? {
    if let glyph = cache[character], glyph.texture.state != .gone {
      return glyph
    }

    // Load the character glyph.
    guard let code = character.unicodeScalars.first?.value
      else { return nil }
    guard FT_Load_Char(face, FT_ULong(code), FT_Int32(FT_LOAD_RENDER)) == 0
      else { return nil }

    // Note: There's an alternative method to get utf32 code points, which relies on Foundation to
    // generate a buffer (see https://stackoverflow.com/questions/47027414/)
    //
    //     "A".data(using: .utf32BigEndian)

    // Generate the texture.
    let ftGlyph = face!.pointee.glyph.pointee
    let width = Int(ftGlyph.bitmap.width)
    let height = Int(ftGlyph.bitmap.rows)

    let image = Image(
      pixels: Data(bytes: ftGlyph.bitmap.buffer, count: width * height),
      width: width,
      height: height,
      format: .gray)
    let texture = Texture(
      source: image,
      wrappingMethod: (u: .clampedToEdge, v: .clampedToEdge))

    // Create the glyph.
    let glyph = Glyph(
      texture: texture,
      size: Vector2(x: Double(width), y: Double(height)),
      bearing: Vector2(x: Double(ftGlyph.bitmap_left), y: Double(ftGlyph.bitmap_top)),
      advance: Double(ftGlyph.advance.x))

    cache[character] = glyph
    return glyph
  }

  /// The handle of the FreeType face object.
  internal let face: FT_Face?

  /// A cache mapping character glyphs to textures.
  internal var cache: [Character: Glyph] = [:]

  deinit {
    FT_Done_Face(face)
  }

}
