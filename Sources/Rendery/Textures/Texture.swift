import CGLFW

/// A 2D texture, stored in GPU memory.
///
/// A texture is essentially an image that is stored in the GPU memory to be used in a material.
public class Texture {

  /// Initializes an empty texture.
  ///
  /// - Parameters:
  ///   - format: The texture's internal data format.
  ///   - wrapMethod: The texture's wrapping behavior.
  internal init(format: InternalFormat, wrapMethod: (u: WrapMethod, v: WrapMethod)) {
    self.format = format
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

  /// The texture's data format in GPU memory.
  public final let format: InternalFormat

  /// A texture's internal data format.
  public enum InternalFormat {

    /// One single red component.
    case red

    /// 4 components in linear RGB color space.
    case rgba

    /// 4 components in standard RGB color space.
    case srgba

    /// 32-bit depth buffers with floating point precision.
    case depth32F

    /// 24-bit depth and 8-bit stencil packed buffers.
    case depth24Stencil8

  }

  /// A method of texture wrapping.
  ///
  /// Texture coordinates are typically given within the range `[0.0, 1.0]` on both axes. This
  /// enumeration describes the different methods that can be used to map coordinates that are
  /// outside this range on each axis.
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
