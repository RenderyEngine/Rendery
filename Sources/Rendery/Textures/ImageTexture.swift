import CGLFW

/// A 2D texture based on a static image.
public final class ImageTexture: Texture {

  /// Initializes a texture from an image source.
  ///
  /// - Parameters:
  ///   - image: The texture's image source.
  ///   - wrapMethod: The texture's wrapping behavior.
  ///   - generateMipmaps: Indicates whether the texture should be generated with mipmaps.
  ///   - requiresFlipping: Indicates whether the image should be flipped vertically before being
  ///     loaded into GPU memory.
  public init(
    image: Image,
    wrapMethod: (u: WrapMethod, v: WrapMethod),
    generateMipmaps: Bool,
    requiresFlipping: Bool
  ) {
    self.image = image
    self.generateMipmaps = generateMipmaps
    self.requiresFlipping = requiresFlipping

    let format: InternalFormat
    switch image.format {
    case .gray:
      format = .red
    case .rgba:
      format = .srgba
    }

    super.init(format: format, wrapMethod: wrapMethod)
  }

  /// Initializes a texture from a texture source.
  ///
  /// - Parameters:
  ///   - image: The texture's image source.
  ///   - wrappingMethod: The texture's wrapping behavior.
  ///   - generateMipmaps: Indicates whether the texture should be generated with mipmaps.
  ///   - requiresFlipping: Indicates whether the image should be flipped vertically before being
  ///     loaded into GPU memory.
  public convenience init(
    image: Image,
    wrapMethod: WrapMethod = .repeat,
    generateMipmaps: Bool = false,
    requiresFlipping: Bool = false
  ) {
    self.init(
      image: image,
      wrapMethod: (wrapMethod, wrapMethod),
      generateMipmaps: generateMipmaps,
      requiresFlipping: requiresFlipping)
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

  /// A flag that indicates whether the image data should be flipped vertically before being loaded
  /// into GPU memory.
  private let requiresFlipping: Bool

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
      // Flip the image data if necessary.
      let pixels: UnsafePointer<UInt8>
      if requiresFlipping {
        let stride = image!.format.componentCountPerPixel
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: stride * width * height)
        for row in 0 ..< height {
          buffer
            .advanced(by: row * stride)
            .assign(from: data.advanced(by: (height - 1 - row) * stride), count: stride)
        }
        pixels = UnsafePointer(buffer)
      } else {
        pixels = data
      }

      let transfer = format.glTransferFormat
      if image!.format == .gray {
        glPixelStorei(GL.UNPACK_ALIGNMENT, 1)
      }

      // Load the texture data into GPU memory.
      glTexImage2D(
        GL.TEXTURE_2D,                      // Texture target
        0,                                  // Mipmap level
        GL.Int(bitPattern: format.glValue), // Internal format in GPU memory
        GL.Size(width),                     // Source width
        GL.Size(height),                    // Source height
        0,                                  // Legacy
        transfer.format,                    // Source format
        transfer.type,                      // Source type (per channel)
        data)                               // Source data

      glPixelStorei(GL.UNPACK_ALIGNMENT, 4)
      if requiresFlipping {
        pixels.deallocate()
      }
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

}
