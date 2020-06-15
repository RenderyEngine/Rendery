import CSTBImage

/// A 2D bitmap image, stored in CPU memory.
public final class Image: TextureSource, InitializableFromFile {

  /// Initializes an image with a matrix of pixel data.
  ///
  /// - Parameters:
  ///   - pixels: An array of `width * height` colors. The matrix should be in row-order and its
  ///     first element should correspond to the top-left corner of the image.
  ///   - width: The image's width, in pixels.
  ///   - height: The image's height, in pixels.
  public init(pixels: [Color], width: Int, height: Int) {
    assert(pixels.count >= width * height)
    self.width = width
    self.height = height

    self.data = .allocate(capacity: 4 * width * height)
    for i in 0 ..< width * height {
      self.data[4 * i] = pixels[i].red
      self.data[4 * i + 1] = pixels[i].green
      self.data[4 * i + 2] = pixels[i].blue
      self.data[4 * i + 3] = pixels[i].alpha
    }
  }

  /// Initializes an image with the content of the specified file.
  ///
  /// - Parameter filename: A full or relative path name specifying the image.
  ///
  /// - Returns:
  ///   An initialized image or `nil` if the specified file could not be located, or if its content
  ///   could not be decoded as an image.
  public init?(contentsOfFile filename: String) {
    var w: Int32 = 0
    var h: Int32 = 0
    var c: Int32 = 0

    self.data = stbi_load(filename, &w, &h, &c, Int32(STBI_rgb_alpha))
    self.width = Int(w)
    self.height = Int(h)
  }

  /// The image's width, in pixels.
  public private(set) var width: Int

  /// The image's height, in pixels.
  public private(set) var height: Int

  public func withUnsafePointer<Result>(
    _ body: (UnsafePointer<UInt8>) throws -> Result
  ) rethrows -> Result {
    return try body(data)
  }

  // MARK: Internal API

  /// The image's data.
  private let data: UnsafeMutablePointer<UInt8>

  deinit {
    data.deallocate()
  }

}
