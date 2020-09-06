import CGLFW

/// A 2D texture whose contents can be modified.
///
/// Unlike an `ImageTexture` object, the contents of a `MutableTexture` object can be modified
/// dynamically, typically by using it as an attachment to a frame buffer.
public final class MutableTexture: Texture {

  public init(width: Int, height: Int, wrapMethod: (u: WrapMethod, v: WrapMethod)) {
    self.width = width
    self.height = height
    super.init(wrapMethod: wrapMethod)

    glGenTextures(1, &handle)
    glBindTexture(GL.TEXTURE_2D, handle)
    glTexImage2D(
      GL.TEXTURE_2D,
      0,
      GL.Int(bitPattern: GL.RGBA),
      GL.Size(width),
      GL.Size(height),
      0,
      GL.RGBA,
      GL.UNSIGNED_BYTE,
      nil)

    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.Int(bitPattern: GL.NEAREST))
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.Int(bitPattern: GL.NEAREST))

    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.Int(wrapMethod.u.glValue))
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.Int(wrapMethod.v.glValue))
  }

  public convenience init(width: Int, height: Int, wrapMethod: WrapMethod = .repeat) {
    self.init(width: width, height: height, wrapMethod: (wrapMethod, wrapMethod))
  }

  /// The texture's width, in pixels.
  public let width: Int

  /// The texture's height, in pixels.
  public let height: Int

}
