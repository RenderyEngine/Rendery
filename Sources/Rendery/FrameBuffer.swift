import GL
import CGLFW
import CGlad

/// A render target that stores its contents in an off-screen buffer.
public final class FrameBuffer: RenderTarget {

  /// Initializes new frame buffer.
  ///
  /// If both `depth` and `stencil` are assigned to the same object, they will be used as a packed
  /// depth-stencil attachment.
  ///
  /// - Parameters:
  ///   - width: The frame buffer's width, in pixels.
  ///   - height: The frame buffer's height, in pixels.
  ///   - colors: A dictionary with the textures to use as the frame buffer's color attachments,
  ///     keyed by the index at which they should be attached.
  ///   - depth: A texture or render buffer to use as frame buffer's depth attachment.
  ///   - stencil: A texture or render buffer to use as frame buffer's stencil attachment.
  ///
  /// - Throws: `InitializationError` if the builder failed to initialize a complete frame buffer
  ///   with its current parameters.
  public init(
    width: Int,
    height: Int,
    colors: [Int: MutableTexture] = [:],
    depth: Attachment? = nil,
    stencil: Attachment? = nil
  ) throws {
    defer { glBindFramebuffer(Int32(GL.FRAMEBUFFER), 0) }

    // Generate a frame buffer object.
    fbo = 0
    glGenFramebuffers(1, &fbo)
    glBindFramebuffer(Int32(GL.FRAMEBUFFER), fbo)
    glWarnError()

    // Bind the color attachments, if any.
    if colors.isEmpty {
      glDrawBuffer(Int32(GL.NONE))
    } else {
      var maxColorAttachments: GL.Int = 0
      glGetIntegerv(Int32(GL.MAX_COLOR_ATTACHMENTS), &maxColorAttachments)

      for (i, texture) in colors {
        guard GL.Int(i) < maxColorAttachments
          else { throw FrameBuffer.InitializationError.attachmentOutOfBounds }

        glFramebufferTexture2D(
          Int32(GL.FRAMEBUFFER),
          Int32(GL.COLOR_ATTACHMENT0 + UInt32(i)),
          Int32(GL.TEXTURE_2D),
          texture.handle,
          0)
        glWarnError()
      }
    }

    // Bind the depth attachment, if any.
    switch depth {
    case .texture(let dtex):
      let attachment: GL.Enum
      if case .texture(let stex) = stencil, dtex === stex {
        attachment = GL.DEPTH_STENCIL_ATTACHMENT
      } else {
        attachment = GL.DEPTH_ATTACHMENT
      }

      glFramebufferTexture2D(Int32(GL.FRAMEBUFFER), Int32(attachment), Int32(GL.TEXTURE_2D), dtex.handle, 0)
      glWarnError()

    case .buffer(let dbuf):
      let attachment: GL.Enum
      if case .buffer(let sbuf) = stencil, dbuf === sbuf {
        attachment = GL.DEPTH_STENCIL_ATTACHMENT
      } else {
        attachment = GL.DEPTH_ATTACHMENT
      }

      glFramebufferRenderbuffer(Int32(GL.FRAMEBUFFER), Int32(attachment), Int32(GL.RENDERBUFFER), dbuf.rbo)
      glWarnError()

    case nil:
      break
    }

    // Bind the stencil attachment, if any.
    switch stencil {
    case .texture(let stex):
      if case .texture(let dtex) = depth, dtex === stex {
        break
      }

      glFramebufferTexture2D(Int32(GL.FRAMEBUFFER), Int32(GL.STENCIL_ATTACHMENT), Int32(GL.TEXTURE_2D), stex.handle, 0)
      glWarnError()

    case .buffer(let sbuf):
      if case .buffer(let dbuf) = depth, dbuf === sbuf {
        break
      }

      glFramebufferRenderbuffer(Int32(GL.FRAMEBUFFER), Int32(GL.STENCIL_ATTACHMENT), Int32(GL.RENDERBUFFER), sbuf.rbo)
      glWarnError()

    case nil:
      break
    }

    // Check that the frame buffer is complete.
    switch glCheckFramebufferStatus(Int32(GL.FRAMEBUFFER)) {
    case Int32(GL.FRAMEBUFFER_COMPLETE):
      break

    case Int32(GL.FRAMEBUFFER_UNSUPPORTED):
      throw InitializationError.unsupportedFormat

    default:
      throw InitializationError.incomplete
    }

    self.colors  = colors
    self.depth   = depth
    self.stencil = stencil
    super.init(width: width, height: height)
  }

  /// Initializes new frame buffer.
  ///
  /// - Parameters:
  ///   - width: The frame buffer's width, in pixels.
  ///   - height: The frame buffer's height, in pixels.
  ///   - colors: A dictionary with the textures to use as the frame buffer's color attachments,
  ///     keyed by the index at which they should be attached.
  ///   - depthAndStencil: A texture or render buffer to use as both the frame buffer's depth and
  ///     stencil attachments.
  ///
  /// - Throws: `InitializationError` if the builder failed to initialize a complete frame buffer
  ///   with its current parameters.
  public convenience init(
    width: Int,
    height: Int,
    colors: [Int: MutableTexture] = [:],
    depthAndStencil: Attachment
  ) throws {
    try self.init(
      width: width,
      height: height,
      colors: colors,
      depth: depthAndStencil,
      stencil: depthAndStencil)
  }

  /// An error raised during the initialization of a new frame buffer.
  public enum InitializationError: Error {

    /// Occurs when a frame buffer is initialized with an invalid attachment.
    case incomplete

    /// Occurs when the format of the attachments configured is not supported.
    case unsupportedFormat

    /// Occurs when a frame buffer is initialized with a color attachment assigned to an index
    /// greater than the maximum supported.
    case attachmentOutOfBounds

  }

  deinit {
    glDeleteFramebuffers(1, &fbo)
  }

  /// A handle to the frame buffer object in GPU memory.
  internal private(set) var fbo: GL.UInt

  /// The buffer's color attachments.
  public let colors: [Int: MutableTexture]

  /// The buffer's depth attchment.
  public let depth: Attachment?

  /// The buffer's stencil attchment.
  public let stencil: Attachment?

  /// A frame buffer attachment.
  public enum Attachment {

    /// A texture attachment.
    case texture(MutableTexture)

    /// A buffer attachment.
    case buffer(RenderBuffer)

    /// Returns the underlying texture, or `nil` if the attachment is not a texture.
    public var asTexture: MutableTexture? {
      if case .texture(let value) = self {
        return value
      } else {
        return nil
      }
    }

    /// Returns the underlying buffer, or `nil` if the attachment is not a buffer.
    public var asBuffer: RenderBuffer? {
      if case .buffer(let value) = self {
        return value
      } else {
        return nil
      }
    }

  }

}
