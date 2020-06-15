/// A data source to initialize a texture.
public protocol TextureSource {

  /// The source's width, in pixels.
  var width: Int { get }

  /// The source's height, in pixels.
  var height: Int { get }

  /// Calls a closure with a pointer to the data source's content.
  ///
  /// The content of the source is a `width * height` buffer representing a matrix of pixels. each
  /// of which defined by a a block of 4 elements deoting its red, green, blue and alpha values of
  /// a pixel, encoded on an 8-bit unsigned integer. The matrix is in a row-major order, where the
  /// first block corresponds to the top-left corner of the image.
  func withUnsafePointer<Result>(
    _ body: (UnsafePointer<UInt8>) throws -> Result
  ) rethrows -> Result

}
