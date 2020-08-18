/// A type that can be initialized from the contents of a file.
public protocol InitializableFromFile {

  /// Initializes a instance of this type with the contents of the specified file.
  ///
  /// - Parameter filename: A full or relative path name specifying the image.
  ///
  /// - Returns: An initialized instance of this type or `nil` if the specified file could not be
  ///   located, or if its contents could not be decoded.
  init?(contentsOfFile filename: String)

}
