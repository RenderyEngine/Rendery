import CGLFW

/// A render target that stores its contents in an off-screen buffer.
public final class FrameBuffer: RenderTarget {

  /// Initializes a frame buffer.
  ///
  /// - Parameter:
  ///   - width: The target’s width, in pixels.
  ///   - height: The target’s height, in pixels.
  public init?(width: Int, height: Int) {
    self.width = width
    self.height = height

    glGenFramebuffers(1, &fbo)
    glBindFramebuffer(GL.FRAMEBUFFER, fbo)
    defer { glBindFramebuffer(GL.FRAMEBUFFER, 0) }

    // Create the buffer's color attachment.
    colorAttachment = RenderTexture(width: width, height: height)
    glFramebufferTexture2D(
      GL.FRAMEBUFFER,
      GL.COLOR_ATTACHMENT0,
      GL.TEXTURE_2D,
      colorAttachment.handle,
      0)

    switch glCheckFramebufferStatus(GL.FRAMEBUFFER) {
    case GL.FRAMEBUFFER_COMPLETE:
      break

    default:
      return nil
    }
  }

  deinit {
    if fbo > 0 {
      glDeleteFramebuffers(1, &fbo)
    }
  }

  /// A handle to the frame buffer object in GPU memory.
  internal private(set) var fbo: GL.UInt = 0

  /// Binds this frame buffer as the active target for rendering operations.
  internal func bind() {
    glBindFramebuffer(GL.FRAMEBUFFER, fbo)
  }

  /// The buffer's color attachment.
  public let colorAttachment: RenderTexture

  /// The buffer's depth and stencil attachment.
  public var depthAndStencilAttachment: RenderBuffer? {
    didSet {
      glBindFramebuffer(GL.FRAMEBUFFER, fbo)
      defer { glBindFramebuffer(GL.FRAMEBUFFER, 0) }

      glFramebufferRenderbuffer(
        GL.FRAMEBUFFER,
        GL.DEPTH_STENCIL_ATTACHMENT,
        GL.RENDERBUFFER,
        depthAndStencilAttachment?.rbo ?? 0)
    }
  }

  public let width: Int

  public let height: Int

  public private(set) var viewports: [Viewport] = []

  public var renderPipeline: RenderPipeline = DefaultRenderPipeline()

  public func update() {
  }

}
