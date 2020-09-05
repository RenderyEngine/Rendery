import CGLFW

/// A texture that can be used as a frame buffer's color attachment.
public class RenderTexture {

  /// Initializes a render texture.
  ///
  /// - Parameter:
  ///   - width: The target’s width, in pixels.
  ///   - height: The target’s height, in pixels.
  public init(width: Int, height: Int) {
    self.width = width
    self.height = height

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
  }

  deinit {
    if handle > 0 {
      glDeleteTextures(1, &handle)
    }
  }

  /// A handle to the texture loaded in GPU memory.
  internal final var handle: GL.UInt = 0

  public final let width: Int

  public final let height: Int

}
