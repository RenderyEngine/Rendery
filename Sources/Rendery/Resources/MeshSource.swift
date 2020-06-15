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

