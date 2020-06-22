import Foundation

/// A data source to initialize a mesh.
public protocol MeshSource {

  /// The vertex data buffer.
  var vertexData: Data { get }

  /// The number of vertices in `vertexData`.
  var vertexCount: Int { get }

  /// The indices of each vertex in the vertex data, used for index drawing if defined.
  ///
  /// An index `i` denotes to the `i`-th vertex in the vertex data. The following example defines
  /// a mesh using a vertex data buffer with two attributes per vertex (position and texture
  /// coordinates) describing two triangles with 4 vertices.
  ///
  ///     let data: [Float] = [
  ///       // Position      // Texture coordinates
  ///       -0.5,  0.5, 0.0, 0.0, 1.0, // top-left vertex
  ///       -0.5, -0.5, 0.0, 0.0, 0.0, // bottom-left vertex
  ///        0.5, -0.5, 0.0, 1.0, 0.0, // bottom-right vertex
  ///        0.5,  0.5, 0.0, 1.0, 1.0, // top-right vertex
  ///     ]
  ///     let indices: [UInt32] = [
  ///       0, 1, 2, // top-left triangle
  ///       0, 2, 3, // bottom-right triangle
  ///     ]
  ///
  /// Index drawing is disabled if this property is left undefined.
  var vertexIndices: [UInt32]? { get }

  /// The descriptors identifying which attributes are defined in the mesh's vertex data.
  var attributeDescriptors: [VertexAttributeDescriptor] { get }

  /// The semantics of the vertex stream.
  var primitiveType: Mesh.PrimitiveType { get }

}

extension MeshSource {

  public var aabb: AxisAlignedBox {
    if let attribute = attributeDescriptors.first(where: { $0.semantic == .position }) {
      assert(attribute.componentType == Float.self)

      var minPoint: Vector3 = Vector3(x: Double(Int.max), y: Double(Int.max), z: Double(Int.max))
      var maxPoint: Vector3 = Vector3(x: Double(Int.min), y: Double(Int.min), z: Double(Int.min))

      vertexData.withUnsafeBytes({ buffer in
        for i in stride(
          from: attribute.offset,
          to: attribute.offset + attribute.stride * vertexCount,
          by: attribute.stride)
        {
          let x = buffer.baseAddress!.advanced(by: i).assumingMemoryBound(to: Float.self)
          if Double(x.pointee) < minPoint.x {
            minPoint.x = Double(x.pointee)
          }
          if Double(x.pointee) > maxPoint.x {
            maxPoint.x = Double(x.pointee)
          }

          let y = x.advanced(by: 1)
          if Double(y.pointee) < minPoint.y {
            minPoint.y = Double(y.pointee)
          }
          if Double(y.pointee) > maxPoint.y {
            maxPoint.y = Double(y.pointee)
          }

          let z = y.advanced(by: 1)
          if Double(z.pointee) < minPoint.z {
            minPoint.z = Double(z.pointee)
          }
          if Double(z.pointee) > maxPoint.z {
            maxPoint.z = Double(z.pointee)
          }
        }
      })

      return AxisAlignedBox(origin: minPoint, dimensions: maxPoint - minPoint)
    } else {
      return AxisAlignedBox(origin: .zero, dimensions: .zero)
    }
  }

}
