import CGLFW

/// A 2D texture based on a static image.
public final class ImageTexture: Texture {

  /// Initializes a texture from an image source.
  ///
  /// - Parameters:
  ///   - image: The texture's image source.
  ///   - wrapMethod: The texture's wrapping behavior.
  ///   - generateMipmaps: Indicates whether the texture should be generated with mipmaps.
  public init(
    image: Image,
    wrapMethod: (u: WrapMethod, v: WrapMethod),
    generateMipmaps: Bool
  ) {
    self.image = image
    self.generateMipmaps = generateMipmaps
    super.init(wrapMethod: wrapMethod)
  }

  /// Initializes a texture from a texture source.
  ///
  /// - Parameters:
  ///   - image: The texture's image source.
  ///   - wrappingMethod: The texture's wrapping behavior.
  ///   - generateMipmaps: Indicates whether the texture should be generated with mipmaps.
  public convenience init(
    image: Image,
    wrapMethod: WrapMethod = .repeat,
    generateMipmaps: Bool = false
  ) {
    self.init(
      image: image,
      wrapMethod: (wrapMethod, wrapMethod),
      generateMipmaps: generateMipmaps)
  }

  internal override var handle: GL.UInt {
    get {
      if !isLoaded {
        load()
      }
      return super.handle
    }

    set { super.handle = newValue }
  }

  /// A flag that indicates whether the texture is loaded.
  private var isLoaded: Bool = false

  /// A flag that indicates whether the texture is generated with mipmaps.
  ///
  /// Mipmaps are sequences of copies of the texture's image, each of which with a progressively
  /// lower resolution. They can improve rendering speed and reduce aliasing artifacts, at the cost
  /// of memory consumption.
  ///
  /// Mimaps can be generated only if the texture's dimensions are a power of two.
  private let generateMipmaps: Bool

  /// The image source for this texture.
  private var image: Image?

  /// Initializes the underlying texture object in GPU memory.
  private func load() {
    assert(AppContext.shared.isInitialized)
    assert(glfwGetCurrentContext() != nil)

    // Generate the texture.
    let (width, height) = (image!.width, image!.height)
    glGenTextures(1, &super.handle)
    assert(super.handle != 0)

    glBindTexture(GL.TEXTURE_2D, super.handle)
    image!.withUnsafePointer({ data in
      // Setup the texture format.
      let format: GL.Enum
      let internalFormat: GL.Int
      switch image!.format {
      case .gray:
        format = GL.RED
        internalFormat = GL.Int(bitPattern: GL.RED)

        // Disable OpenGL's byte-alignment restriction, since there's only one channel.
        glPixelStorei(GL.UNPACK_ALIGNMENT, 1)

      case .rgba:
        format = GL.RGBA
        internalFormat = GL.Int(bitPattern: GL.SRGB_ALPHA)
        glPixelStorei(GL.UNPACK_ALIGNMENT, 4)
      }

      // Load the texture data into GPU memory.
      glTexImage2D(
        GL.TEXTURE_2D,                 // Texture target
        0,                             // Mipmap level
        internalFormat,                // Internal format in GPU memory
        GL.Size(width),                // Source width
        GL.Size(height),               // Source height
        0,                             // Legacy
        format,                        // Source format
        glTypeSymbol(of: UInt8.self)!, // Source type (per channel)
        data)                          // Source data
    })

    // Generate mipmaps, if requested.
    if generateMipmaps {
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
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.Int(wrapMethod.u.glValue))
    glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.Int(wrapMethod.v.glValue))

    // Dispose of the data source.
    image = nil
    isLoaded = true
  }

  deinit {
    if handle > 0 {
      glDeleteTextures(1, &handle)
      handle = 0
    }
  }

}
