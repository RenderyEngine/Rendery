/// A collision shape that is built from assembling other shapes.
///
/// A compound shape is typically made up of two or more simpler shapes to build a more complex
/// shape. For instance, you may combine five prisms to produce the shape of a table, one for its
/// plate and four for its legs.
public struct CompoundShape: CollisionShape {

  /// Initializes a compound shape with a collection of shapes and their respective transforms.
  ///
  /// - Parameter shapes: An array of pairs `(shape, transform)` where `shape` is a collision shape
  ///   and `transform` is a matrix representing how it is translated, rotated and oriented in the
  ///   compound shape's local space.
  public init(shapes: [(shape: CollisionShape, transform: Matrix4)]) {
    self.shapes = shapes
  }

  var shapes: [(shape: CollisionShape, transform: Matrix4)]

  public func collisionDistance(
    with ray: Ray,
    translation: Vector3,
    rotation: Quaternion,
    scale: Vector3,
    isCullingEnabled: Bool
  ) -> Double? {
    var closest: Double? = nil

    let model = Matrix4(translation: translation, rotation: rotation, scale: scale)
    for (shape, local) in shapes {
      let (loc, rot, scale) = (model * local).decompose()
      guard let distance = shape.collisionDistance(
        with: ray,
        translation: loc,
        rotation: rot,
        scale: scale,
        isCullingEnabled: isCullingEnabled)
      else { continue }

      if closest == nil || abs(closest!) > abs(distance) {
        closest = distance
      }
    }

    return closest
  }

}
