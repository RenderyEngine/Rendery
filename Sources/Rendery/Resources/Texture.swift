import CGLFW

/// A 2D texture image, stored in GPU memory.
public final class Texture: GraphicsResource {

  /// Initializes a texture from a texture source.
  ///
  /// - Parameters:
  ///   - source: The texture's source.
  ///   - wrappingMethod: The texture's wrapping behavior.
  ///   - usesMipmaps: Indicates whether the texture should be generated with mipmaps.
  public init<Source>(
    source: Source,
    wrappingMethod: (u: WrappingMethod, v: WrappingMethod) = (.repeat, .repeat),
    usesMipmaps: Bool = false
  ) where Source: TextureSource {
    self.wrappingMethod = wrappingMethod
    self.usesMipmaps = usesMipmaps
    self.source = source
    self.state = .unloaded
  }

  /// The method that should be used to wrap the texture on a mesh.
  ///
  /// Texture coordinates are typically given within the range `0.0 ... 1.0` on both axes. This
  /// property specifies how a renderer should behave for pairs of coordinates that are outside
  /// this range on each axis.
  public let wrappingMethod: (u: WrappingMethod, v: WrappingMethod)

  /// A method of texture wrapping.
  public enum WrappingMethod {

    /// The texture is clamped to the mesh's borders.
    case clampedToBorder

    /// The texture is clamped to the mesh's edges.
    case clampedToEdge

    /// Similar to `repeat`, but the textured is mirrored wich each repeat.
    case mirroredRepeat

    /// The texture is repeated.
    case `repeat`

  }

  /// A flag that indicates whether the texture uses mipmaps.
  ///
  /// Mipmaps are sequences of copies of the texture's image, each of which with a progressively
  /// lower resolution. They can improve rendering speed and reduce aliasing artifacts, at the cost
  /// of memory consumption.
  ///
  /// Mimaps can be generated only if the texture's dimensions are a power of two.
  let usesMipmaps: Bool

  /// The default texture, made of a single white pixel image.
  public static var `default`: Texture {
    if _default == nil || _default!.state == .gone {
      _default = Texture(source: Image(pixels: [.white], width: 1, height: 1))
    }

    return _default!
  }

  /// The actual reference to the default texture.
  private static var _default: Texture?

  // MARK: Internal API

  /// A handle to the texture loaded in GPU memory.
  internal var handle: GL.UInt = 0

  /// The data source for this texture.
  private var source: TextureSource?

  var state: GraphicsResourceState

  internal final func load() {
    assert(state != .gone)
    guard state != .loaded
      else { return }

    assert(AppContext.shared.isInitialized)
    assert(glfwGetCurrentContext() != nil)
    assert(source != nil)

    // Generate the texture.
    let (width, height) = (source!.width, source!.height)
    glGenTextures(1, &self.handle)
    glBindTexture(GL.TEXTURE_2D, self.handle)
    source!.withUnsafePointer({ data in
      // Mirror the image, as OpenGL expects the first pixel to be at the bottom-left, and
      // premultiplie the alpha channel for blending.
      var buffer: UnsafeMutablePointer<UInt8> = .allocate(capacity: 4 * width * height)
      defer { buffer.deallocate() }
      let w4 = width * 4
      for row in 0 ..< height {
        let base = buffer.advanced(by: row * w4)
        base.assign(from: data.advanced(by: (height - 1 - row) * w4), count: w4)

        // FIXME: Add an option to choose whether alpha should be pre-multiplied.
        for col in stride(from: 0, to: w4, by: 4) {
          base[col + 0] = UInt8(Double(base[col + 0]) * Double(base[col + 3]) / 255.0)
          base[col + 1] = UInt8(Double(base[col + 1]) * Double(base[col + 3]) / 255.0)
          base[col + 2] = UInt8(Double(base[col + 2]) * Double(base[col + 3]) / 255.0)
        }
      }

      // Load the texture data into GPU memory.
      let format = source!.format.glValue
      if format == GL.RED {
        // Disable OpenGL's byte-alignment restriction, since there's only one channel.
        glPixelStorei(GL.UNPACK_ALIGNMENT, 1)
      }

      glTexImage2D(
        GL.TEXTURE_2D,                 // Texture target
        0,                             // Mipmap level
        GL.Int(bitPattern: format),    // Format in GPU memory
        GL.Size(width),                // Source width
        GL.Size(height),               // Source height
        0,                             // Legacy
        format,                        // Source format
        glTypeSymbol(of: UInt8.self)!, // Source type (per channel)
        data)                          // Source data
    })

    // Generate mipmaps, if requested.
    if usesMipmaps {
      // Check that the image's dimensions are a power of two.
      if (width & (width - 1) != 0 || height & (height - 1) != 0) {
        LogManager.main.log(
          "Texture's dimensions are not a power of two, ignoring mipmaps generation.",
          level: .warning)
      } else {
        glGenerateMipmap(GL.TEXTURE_2D)
      }
    } else {
      // Setup nearest neighbor filtering.
      // Required if mipmaps are disabled (https://stackoverflow.com/questions/8064420)
      glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.Int(bitPattern: GL.NEAREST))
      glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.Int(bitPattern: GL.NEAREST))
    }

    // Setup the texture's wrapping method.
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.Int(wrappingMethod.u.glValue))
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.Int(wrappingMethod.v.glValue))

    // Dispose of the data source.
    source = nil

    state = .loaded
    assert(handle != 0)
    LogManager.main.log("Texture '\(handle)' successfully loaded.", level: .debug)

    // Bind the texture's lifetime to the app context.
    AppContext.shared.graphicsResourceManager.store(self)
  }

  func unload() {
    if handle > 0 {
      glDeleteTextures(1, &handle)
      LogManager.main.log("Texture '\(handle)' successfully unloaded.", level: .debug)
      handle = 0
    }

    state = .gone
  }

  deinit {
    unload()
    AppContext.shared.graphicsResourceManager.remove(self)
  }

}
