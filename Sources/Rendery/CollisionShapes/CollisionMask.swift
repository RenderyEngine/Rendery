/// A collision mask.
///
/// This structure is a simple `OptionSet` backed by an integer value. It is intended to be
/// extended in your own code so that you can add as many named options as needed.
public struct CollisionMask: OptionSet {

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public let rawValue: Int

  /// The category for objects that should never interact with any collision test.
  public static let none = CollisionMask(rawValue: 0)

  /// The default category for all objects.
  public static let `default` = CollisionMask(rawValue: 1)

  /// The category for objects that shouls interact with all collision tests.
  public static let all = CollisionMask(rawValue: ~0)

  /// Returns a the union of two collision masks.
  ///
  /// - Parameters:
  ///   - lhs: The first collision mask.
  ///   - rhs: The second collision mask.
  public static func | (lhs: CollisionMask, rhs: CollisionMask) -> CollisionMask {
    return lhs.union(rhs)
  }

}
