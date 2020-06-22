/// A free-form, detailed collision shape built from a mesh.
///
/// This collision shape is built directly from the triangles defining a mesh's geometry. This
/// allows for very detailed but equally computationally expensive collision tests.
public struct MeshShape: CollisionShape {

  /// Initializes a mesh collision shape from a set of triangles.
  ///
  /// - Parameter triangles: An array with the triangles that from the shape.
  public init(triangles: [Triangle]) {
    self.triangles = triangles
  }

  /// Initializes a mesh collision shape from a mesh source.
  ///
  /// - Parameter source: The mesh's source. The source must contains vertex positions and be
  ///   defined  with the primitive type `triangles`.
  public init?(source: MeshSource) {
    guard source.primitiveType == .triangles
      else { return nil }
    guard let descriptor = source.attributeDescriptors.first(where: { $0.semantic == .position })
      else { return nil }

    var positions: [Vector3] = []

    for i in stride(from: descriptor.offset, to: source.vertexData.count, by: descriptor.stride) {
      let position = source.vertexData.withUnsafeBytes({ (buffer) -> Vector3? in
        switch ObjectIdentifier(descriptor.componentType) {
        case ObjectIdentifier(Float.self):
          return extractVector(from:  buffer.baseAddress!.advanced(by: i), typedAs: Float.self)
        case ObjectIdentifier(Double.self):
          return extractVector(from:  buffer.baseAddress!.advanced(by: i), typedAs: Double.self)
        default:
          return nil
        }
      })

      guard position != nil
        else { return nil }
      positions.append(position!)
    }

    self.triangles = []
    if let indices = source.vertexIndices {
      for i in stride(from: 0, to: indices.count, by: 3) {
        self.triangles.append(Triangle(
          a: positions[Int(indices[i])],
          b: positions[Int(indices[i + 1])],
          c: positions[Int(indices[i + 2])]))
      }
    } else {
      for i in stride(from: 0, to: positions.count, by: 3) {
        self.triangles.append(Triangle(
          a: positions[i],
          b: positions[i + 1],
          c: positions[i + 2]))
      }
    }
  }

  /// The triangles defining the collision shape.
  public var triangles: [Triangle]

  public func collisionDistance(
    with ray: Ray,
    translation: Vector3,
    rotation: Quaternion,
    scale: Vector3,
    isCullingEnabled: Bool
  ) -> Double? {
    var closest: Double? = nil

    for triangle in triangles {
      guard let distance = ray.collisionDistance(
        with: triangle,
        translation: translation,
        rotation: rotation,
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

private func extractVector<T>(from pointer: UnsafeRawPointer, typedAs: T.Type) -> Vector3
  where T: BinaryFloatingPoint
{
  let base = pointer.assumingMemoryBound(to: T.self)
  return Vector3(
    x: Double(base.pointee),
    y: Double(base.advanced(by: 1).pointee),
    z: Double(base.advanced(by: 2).pointee))
}
