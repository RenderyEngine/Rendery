import CGLFW

/// A 2D texture, stored in GPU memory.
///
/// A texture is essentially an image that is stored in the GPU memory to be used in a material.
public class Texture {

  /// Initializes an empty texture.
  ///
  /// - Parameter wrapMethod: The texture's wrapping behavior.
  internal init(wrapMethod: (u: WrapMethod, v: WrapMethod)) {
    self.wrapMethod = wrapMethod
  }

  deinit {
    if handle > 0 {
      glDeleteTextures(1, &handle)
      handle = 0
    }
  }

  /// A handle to the underlying texture object in GPU memory.
  internal var handle: GL.UInt = 0

  /// The method that should be used to wrap the texture on a mesh.
  ///
  /// Texture coordinates are typically given within the range `0.0 ... 1.0` on both axes. This
  /// property specifies how a map coordinates that are outside this range on each axis.
  public final let wrapMethod: (u: WrapMethod, v: WrapMethod)

  /// A method of texture wrapping.
  public enum WrapMethod {

    /// The texture is clamped to the mesh's borders.
    case clampedToBorder

    /// The texture is clamped to the mesh's edges.
    case clampedToEdge

    /// Similar to `repeat`, but the textured is mirrored wich each repeat.
    case mirroredRepeat

    /// The texture is repeated.
    case `repeat`

  }

  /// The default texture, made of a single white pixel image.
  public static var `default` = ImageTexture(image: Image(pixels: [.white], width: 1, height: 1))

}
