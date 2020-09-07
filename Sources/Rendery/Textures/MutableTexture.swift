import CGLFW

/// A 2D texture whose contents can be modified.
///
/// Unlike an `ImageTexture` object, the contents of a `MutableTexture` object can be modified
/// dynamically, typically by using it as an attachment to a frame buffer.
public final class MutableTexture: Texture {

  public init(
    width: Int,
    height: Int,
    format: InternalFormat,
    wrapMethod: (u: WrapMethod, v: WrapMethod)
  ) {
    self.width = width
    self.height = height
    super.init(format: format, wrapMethod: wrapMethod)

    let transfer = format.glTransferFormat

    glGenTextures(1, &handle)
    glBindTexture(GL.TEXTURE_2D, handle)
    glTexImage2D(
      GL.TEXTURE_2D,
      0,
      GL.Int(bitPattern: format.glValue),
      GL.Size(width),
      GL.Size(height),
      0,
      transfer.format,
      transfer.type,
      nil)

    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.Int(bitPattern: GL.NEAREST))
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.Int(bitPattern: GL.NEAREST))

    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.Int(wrapMethod.u.glValue))
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.Int(wrapMethod.v.glValue))
  }

  public convenience init(
    width: Int,
    height: Int,
    format: InternalFormat = .srgba,
    wrapMethod: WrapMethod = .repeat
  ) {
    self.init(width: width, height: height, format: format, wrapMethod: (wrapMethod, wrapMethod))
  }

  /// The texture's width, in pixels.
  public let width: Int

  /// The texture's height, in pixels.
  public let height: Int

}
