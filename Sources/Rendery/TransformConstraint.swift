/// A constraint that can alters the transform of a node to satisfy a set of relationships.
///
/// A transform constraint is essentially a helper function to compute the transform properties of
/// a node so that it satisfies a set or relationships.
public protocol TransformConstraint {

  /// Applies the constraint on the specified node.
  ///
  /// - Parameter node: The node on which the constraint should be applied.
  func apply(on node: Node3D)

  /// The nodes on which this constraint depends.
  var dependencies: [Node3D] { get }

}

/// A constraint that controls a node's orientation so that it is always looking at another node.
public struct LookAtConstraint: TransformConstraint {

  /// Initializes a "look at" constraint.
  ///
  /// - Parameters:
  ///   - target: The target of the constraint.
  ///   - up: A normalized up vector specifying how the observer is oriented.
  public init(target: Node3D, up: Vector3 = .unitY) {
    self.target = target
    self.up = up
  }

  /// The target of the constraint.
  public var target: Node3D

  /// The direction that is aligned with the "up" direction of the node under constraint.
  public var up: Vector3

  /// Applies the constraint on the specified node.
  ///
  /// The method overrides `node.rotation` so that it is oriented at the constraint's target. The
  /// value is obtained by subtracting the parent's rotation (if any), so that the node's total
  /// scene rotation (i.e., `node.sceneRotation`) matches the result of a "look at" matrix.
  ///
  /// - Parameter node: The node on which the constraint should be applied.
  public func apply(on node: Node3D) {
    let targetPosition = target.sceneTranslation
    let lookAt = Matrix4.lookAt(from: node.sceneTranslation, to: targetPosition, up: up)

    let rotation = Quaternion(matrix: lookAt)
    if let parentSceneRotation = node.parent?.sceneRotation {
      node.rotation = parentSceneRotation.inverted * rotation
    } else {
      node.rotation = rotation
    }
  }

  public var dependencies: [Node3D] { [target] }

}
