/// A data source to initialize a texture.
public protocol TextureSource {

  /// The source's width, in pixels.
  var width: Int { get }

  /// The source's height, in pixels.
  var height: Int { get }

  /// The pixel data format.
  var format: Image.PixelFormat { get }

  /// Calls a closure with a pointer to the data source's content.
  ///
  /// The content of the source is a `width * height` buffer representing a matrix of pixels, each
  /// of which defined by a `n` consecutive bytes (i.e., 8-bit unsigned integers) representing the
  /// `n` different color channels composing the pixel's color. The matrix is in a row-major order,
  /// where the first block corresponds to the top-left corner of the image.
  func withUnsafePointer<Result>(
    _ body: (UnsafePointer<UInt8>) throws -> Result
  ) rethrows -> Result

}
