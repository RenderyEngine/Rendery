import Foundation

/// A concrete mesh source.
public struct MeshData: MeshSource {

  /// Initializes a mesh data object.
  public init(
    vertexData: Data,
    vertexCount: Int,
    vertexIndices: [UInt32]? = nil,
    attributeDescriptors: [VertexAttributeDescriptor],
    primitiveType: Mesh.PrimitiveType = .triangles
  ) {
    self.vertexData = vertexData
    self.vertexCount = vertexCount

    self.vertexIndices = vertexIndices
    self.attributeDescriptors = attributeDescriptors
    self.primitiveType = primitiveType

    // TODO: Run some sanity checks.
  }

  public init<T>(
    vertexData: Array<T>,
    vertexCount: Int,
    vertexIndices: [UInt32]? = nil,
    attributeDescriptors: [VertexAttributeDescriptor],
    primitiveType: Mesh.PrimitiveType = .triangles
  ) {
    let data = vertexData.withUnsafeBufferPointer({ buffer in Data(buffer: buffer) })
    self.init(
      vertexData: data,
      vertexCount: vertexCount,
      vertexIndices: vertexIndices,
      attributeDescriptors: attributeDescriptors,
      primitiveType: primitiveType)
  }

  public let vertexData: Data

  public let vertexCount: Int

  public let vertexIndices: [UInt32]?

  public let attributeDescriptors: [VertexAttributeDescriptor]

  public let primitiveType: Mesh.PrimitiveType

}
