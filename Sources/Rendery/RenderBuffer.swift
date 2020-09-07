import CGLFW

/// A render buffer object that can be used as a frame buffer's attachment.
public final class RenderBuffer {

  /// Initializes a render buffer.
  ///
  /// - Parameter:
  ///   - width: The buffer’s width, in pixels.
  ///   - height: The buffer’s height, in pixels.
  ///   - format: The buffer's internal format.
  public init(width: Int, height: Int, format: Texture.InternalFormat) {
    glGenRenderbuffers(1, &rbo)
    glBindRenderbuffer(GL.RENDERBUFFER, rbo)
    glRenderbufferStorage(GL.RENDERBUFFER, format.glValue, GL.Size(width), GL.Size(height))
  }

  deinit {
    if rbo > 0 {
      glDeleteRenderbuffers(1, &rbo)
    }
  }

  /// A handle to the render buffer object in GPU memory.
  internal private(set) final var rbo: GL.UInt = 0

}
