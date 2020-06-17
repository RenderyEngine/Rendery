import CGLFW

// MARK: Types and constants

/// A namespace for type aliases various OpenGL constants.
internal enum GL {

  // MARK: Type aliases

  typealias Bool      = Swift.Int32
  typealias BitField  = Swift.UInt32
  typealias Int       = Swift.Int32
  typealias UInt      = Swift.UInt32
  typealias Enum      = Swift.UInt32
  typealias Size      = Swift.Int32

  // MARK: Constants

  static var COLOR_BUFFER_BIT     : BitField { BitField(GL_COLOR_BUFFER_BIT) }
  static var DEPTH_BUFFER_BIT     : BitField { BitField(GL_DEPTH_BUFFER_BIT) }
  static var SCISSOR_TEST         : BitField { BitField(GL_SCISSOR_TEST) }

  static var ARRAY_BUFFER         : Enum { Enum(GL_ARRAY_BUFFER) }
  static var BLEND                : Enum { Enum(GL_BLEND) }
  static var CLAMP_TO_BORDER      : Enum { Enum(GL_CLAMP_TO_BORDER) }
  static var CLAMP_TO_EDGE        : Enum { Enum(GL_CLAMP_TO_EDGE) }
  static var COMPILE_STATUS       : Enum { Enum(GL_COMPILE_STATUS) }
  static var DEPTH_TEST           : Enum { Enum(GL_DEPTH_TEST) }
  static var DYNAMIC_DRAW         : Enum { Enum(GL_DYNAMIC_DRAW) }
  static var ELEMENT_ARRAY_BUFFER : Enum { Enum(GL_ELEMENT_ARRAY_BUFFER) }
  static var FALSE                : Bool { Bool(GL_FALSE) }
  static var FRAGMENT_SHADER      : Enum { Enum(GL_FRAGMENT_SHADER) }
  static var INFO_LOG_LENGTH      : Enum { Enum(GL_INFO_LOG_LENGTH) }
  static var LINEAR               : Enum { Enum(GL_LINEAR) }
  static var LINES                : Enum { Enum(GL_LINES) }
  static var LINK_STATUS          : Enum { Enum(GL_LINK_STATUS) }
  static var MIRRORED_REPEAT      : Enum { Enum(GL_MIRRORED_REPEAT) }
  static var NEAREST              : Enum { Enum(GL_NEAREST) }
  static var ONE                  : Enum { Enum(GL_ONE) }
  static var ONE_MINUS_SRC_ALPHA  : Enum { Enum(GL_ONE_MINUS_SRC_ALPHA) }
  static var POINTS               : Enum { Enum(GL_POINTS) }
  static var REPEAT               : Enum { Enum(GL_REPEAT) }
  static var RGBA                 : Enum { Enum(GL_RGBA) }
  static var SRC_ALPHA            : Enum { Enum(GL_SRC_ALPHA) }
  static var TEXTURE_2D           : Enum { Enum(GL_TEXTURE_2D) }
  static var TEXTURE_HEIGHT       : Enum { Enum(GL_TEXTURE_HEIGHT) }
  static var TEXTURE_MIN_FILTER   : Enum { Enum(GL_TEXTURE_MIN_FILTER) }
  static var TEXTURE_WIDTH        : Enum { Enum(GL_TEXTURE_WIDTH) }
  static var TEXTURE_WRAP_S       : Enum { Enum(GL_TEXTURE_WRAP_S) }
  static var TEXTURE_WRAP_T       : Enum { Enum(GL_TEXTURE_WRAP_T) }
  static var TEXTURE0             : Enum { Enum(GL_TEXTURE0) }
  static var TRIANGLES            : Enum { Enum(GL_TRIANGLES) }
  static var TRUE                 : Enum { Enum(GL_TRUE) }
  static var VERTEX_SHADER        : Enum { Enum(GL_VERTEX_SHADER) }

}

// MARK: Function convenience overloads

/// Convenience wrapper around `glClearColor`.
internal func glClearColor(_ color: Color) {
  glClearColor(
    Float(color.red) / 255.0,
    Float(color.green) / 255.0,
    Float(color.blue) / 255.0,
    Float(color.alpha) / 255.0)
}

/// Convenience overload of `glScissor`.
internal func glScissor(region: Rectangle) {
  glScissor(GL.Int(region.minX), GL.Int(region.minY), GL.Int(region.width), GL.Int(region.height))
}

/// Convenience overload of `glViewport`.
internal func glViewport(region: Rectangle) {
  glViewport(GL.Int(region.minX), GL.Int(region.minY), GL.Int(region.width), GL.Int(region.height))
}

// MARK: Converters

extension Mesh.PrimitiveType {

  internal var glValue: GL.Enum {
    switch self {
    case .triangles: return GL.TRIANGLES
    case .lines    : return GL.LINES
    case .points   : return GL.POINTS
    }
  }

}

extension Texture.WrappingMethod {

  internal init?(glValue: GL.Enum) {
    switch glValue {
    case GL.CLAMP_TO_BORDER : self = .clampedToBorder
    case GL.CLAMP_TO_EDGE   : self = .clampedToEdge
    case GL.MIRRORED_REPEAT : self = .mirroredRepeat
    case GL.REPEAT          : self = .repeat
    default                 : return nil
    }
  }

  internal var glValue: GL.Enum {
    switch self {
    case .clampedToBorder : return GL.CLAMP_TO_BORDER
    case .clampedToEdge   : return GL.CLAMP_TO_EDGE
    case .mirroredRepeat  : return GL.MIRRORED_REPEAT
    case .repeat          : return GL.REPEAT
    }
  }

}

internal func glTypeSymbol(of type: Any.Type) -> GL.Enum? {
  if type == Int8.self   { return GL.Enum(GL_BYTE) }
  if type == UInt8.self  { return GL.Enum(GL_UNSIGNED_BYTE) }
  if type == Int16.self  { return GL.Enum(GL_SHORT) }
  if type == UInt16.self { return GL.Enum(GL_UNSIGNED_SHORT) }
  if type == Int32.self  { return GL.Enum(GL_INT) }
  if type == UInt32.self { return GL.Enum(GL_UNSIGNED_INT) }
  if type == Float.self  { return GL.Enum(GL_FLOAT) }
  if type == Double.self { return GL.Enum(GL_DOUBLE) }

  return nil
}
