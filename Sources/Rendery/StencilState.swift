import CGLFW

/// The configuration of the stencil state of a render system.
public class StencilState {

  /// A flag that indicates whether stencil testing is enabled.
  public var isEnabled = false {
    didSet { glToggle(capability: GL.STENCIL_TEST, isEnabled: isEnabled) }
  }

  public func setWriteMask(_ mask: UInt8) {
    glStencilMask(GL.UInt(mask))
  }

  public func setFunction(_ function: StencilCompareFunction) {
    function.assign(for: GL.FRONT_AND_BACK)
  }

  public func setActions(
    onStencilFailure: StencilAction,
    onStencilSuccessAndDepthFailure: StencilAction,
    onStencilAndDepthSuccess: StencilAction
  ) {
    glStencilOpSeparate(
      GL.FRONT_AND_BACK,
      onStencilFailure.glValue,
      onStencilSuccessAndDepthFailure.glValue,
      onStencilAndDepthSuccess.glValue)
  }

}

/// The behavior of the stencil testing for a particular direction.
public struct StencilBehavior {

  /// The face affected by this behavior configuration.
  fileprivate let face: GL.Enum

  /// The function that is used to test polygons facing this direction.
  public var comparison: StencilCompareFunction {
    didSet { comparison.assign(for: face) }
  }

  /// The action to take when the stencil test fails.
  public var onStencilFailure: StencilAction {
    didSet { updateActions() }
  }

  /// The action to take when the stencil test passes, but the depth test fails.
  public var onStencilSuccessAndDepthFailure: StencilAction {
     didSet { updateActions() }
   }

  /// The action to take when the stencil test passes and the depth test passes or is disabled.
  public var onStencilAndDepthSuccess: StencilAction {
     didSet { updateActions() }
   }

  private func updateActions() {
    glStencilOpSeparate(
      face,
      onStencilFailure.glValue,
      onStencilSuccessAndDepthFailure.glValue,
      onStencilAndDepthSuccess.glValue)
  }

  /// The mask that is used when writing to the buffer.
  ///
  /// For each individual bit, a value of `1` indicates that the corresponding position can be
  /// modified, whereas a value of `0` precents the corresponding value from being overwritten.
  public var mask: UInt8 = 0xff {
    didSet { glStencilMaskSeparate(face, GL.UInt(mask)) }
  }

}

/// The configuration of a stencil compare function.
public enum StencilCompareFunction {

  /// Always passes.
  case always(reference: UInt8, mask: UInt8)

  /// Always fails.
  case never(reference: UInt8, mask: UInt8)

  /// Passes if `(reference & mask) < (stencil & mask)`.
  case lesser(reference: UInt8, mask: UInt8)

  /// Passes if `(reference & mask) <= (stencil & mask)`.
  case lesserOrEqual(reference: UInt8, mask: UInt8)

  /// Passes if `(reference & mask) > (stencil & mask)`.
  case greater(reference: UInt8, mask: UInt8)

  /// Passes if `(reference & mask) >= (stencil & mask)`.
  case greaterOrEqual(reference: UInt8, mask: UInt8)

  /// Passes if `(reference & mask) == (stencil & mask)`.
  case equal(reference: UInt8, mask: UInt8)

  /// Passes if `(reference & mask) != (stencil & mask)`.
  case notEqual(reference: UInt8, mask: UInt8)

  fileprivate func assign(for face: GL.Enum) {
    switch self {
    case .always(let reference, let mask):
      glStencilFuncSeparate(face, GL.ALWAYS, GL.Int(reference), GL.UInt(mask))

    case .never(let reference, let mask):
      glStencilFuncSeparate(face, GL.NEVER, GL.Int(reference), GL.UInt(mask))

    case .lesser(let reference, let mask):
      glStencilFuncSeparate(face, GL.LESS, GL.Int(reference), GL.UInt(mask))

    case .lesserOrEqual(let reference, let mask):
      glStencilFuncSeparate(face, GL.LEQUAL, GL.Int(reference), GL.UInt(mask))

    case .greater(let reference, let mask):
      glStencilFuncSeparate(face, GL.GREATER, GL.Int(reference), GL.UInt(mask))

    case .greaterOrEqual(let reference, let mask):
      glStencilFuncSeparate(face, GL.GEQUAL, GL.Int(reference), GL.UInt(mask))

    case .equal(let reference, let mask):
      glStencilFuncSeparate(face, GL.EQUAL, GL.Int(reference), GL.UInt(mask))

    case .notEqual(let reference, let mask):
      glStencilFuncSeparate(face, GL.NOTEQUAL, GL.Int(reference), GL.UInt(mask))
    }
  }

}

/// An action to perform depending on the outcome of a stencil test.
public enum StencilAction {

  /// Keeps the current buffer value.
  case keep

  /// Sets the buffer value to `0`.
  case zero

  /// Sets the buffer value to the comparison function's reference value.
  case replace

  /// Increments the buffer value.
  ///
  /// If `clamped` is `true`, then the buffer value is clamped to `255`. Otherwise, it is set to
  /// `0` when incremented from `255`.
  case increment(clamped: Bool)

  /// Decrements the buffer value.
  ///
  /// If `clamped` is `true`, then the buffer value is clamped to `0`. Otherwise, it is set to
  /// `255` when decremented from `0`.
  case decrement(clamped: Bool)

  /// Inverts the binary representation of the buffer value.
  case invert

  /// The OpenGL enum value corresponding to this action.
  fileprivate var glValue: GL.Enum {
    switch self {
    case .keep            : return GL.KEEP
    case .zero            : return GL.ZERO
    case .replace         : return GL.REPLACE
    case .increment(true) : return GL.INCR
    case .increment(false): return GL.INCR_WRAP
    case .decrement(true) : return GL.DECR
    case .decrement(false): return GL.DECR_WRAP
    case .invert          : return GL.INVERT
    }
  }

}
