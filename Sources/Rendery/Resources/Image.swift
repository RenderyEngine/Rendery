import CSTBImage
import Foundation

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

  /// Initializes an image with the specified data.
  ///
  /// - Parameter data: A data object containing the image data.
  ///
  /// - Returns:
  ///   An initialized image or `nil` if the specified data could not be decoded as an image.
  public init?(data: Data) {
    var w: Int32 = 0
    var h: Int32 = 0
    var c: Int32 = 0

    // FIXME: Handle errors
    self.data = data.withUnsafeBytes({
      (bytes: UnsafeRawBufferPointer) -> UnsafeMutablePointer<UInt8> in
      let base = bytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
      return stbi_load_from_memory(base, Int32(bytes.count), &w, &h, &c, Int32(STBI_rgb_alpha))
    })

    self.width = Int(w)
    self.height = Int(h)
  }

  /// Initializes an image with the contents of the specified file.
  ///
  /// - Parameter filename: A full or relative path name specifying the image.
  ///
  /// - Returns:
  ///   An initialized image or `nil` if the specified file could not be located, or if its content
  ///   could not be decoded as an image.
  public convenience init?(contentsOfFile filename: String) {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filename))
      else { return nil }
    self.init(data: data)
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
