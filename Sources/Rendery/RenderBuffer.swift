import CGLFW

/// A render buffer object that can be used as a frame buffer's attachment.
public final class RenderBuffer {

  /// Initializes a render buffer.
  ///
  /// - Parameter:
  ///   - width: The target’s width, in pixels.
  ///   - height: The target’s height, in pixels.
  ///   - internalFormat: The texture's internal format.
  public init(width: Int, height: Int) {
    glGenRenderbuffers(1, &rbo)
    glBindRenderbuffer(GL.RENDERBUFFER, rbo)
    glRenderbufferStorage(GL.RENDERBUFFER, GL.DEPTH24_STENCIL8, GL.Size(width), GL.Size(height))
  }

  deinit {
    if rbo > 0 {
      glDeleteRenderbuffers(1, &rbo)
    }
  }

  /// A handle to the render buffer object in GPU memory.
  internal private(set) final var rbo: GL.UInt = 0

}
