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

  /// Initializes a mesh data object.
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

  /// Initializes a mesh data by backing a tranfromation matrix in another mesh source.
  ///
  /// - Parameter transform: A matrix representing the transformations to bake.
  public init(baking transform: Matrix4, into source: MeshSource) {
    self.vertexCount = source.vertexCount
    self.vertexIndices = source.vertexIndices
    self.attributeDescriptors = source.attributeDescriptors
    self.primitiveType = source.primitiveType

    // Copy the vertex data.
    let data = UnsafeMutableRawBufferPointer.allocate(
      byteCount: source.vertexData.count,
      alignment: MemoryLayout<UInt8>.alignment)
    let base = data.baseAddress!
    source.vertexData.copyBytes(to: data)

    // Transform the source's vertex positions and normals, if any.
    let semantics: [VertexAttributeDescriptor.Semantic] = [.position, .normal]
    for semantic in semantics {
      if let attribute = attributeDescriptors.first(where: { $0.semantic == semantic }) {
        assert(attribute.componentType == Float.self)

        for i in stride(from: attribute.offset, to: data.count, by: attribute.stride) {
          let ptr = base.advanced(by: i).assumingMemoryBound(to: Float.self)
          let vec = transform * Vector3(x: Double(ptr[0]), y: Double(ptr[1]), z: Double(ptr[2]))
          ptr[0] = Float(vec.x)
          ptr[1] = Float(vec.y)
          ptr[2] = Float(vec.z)
        }
      }
    }

    self.vertexData = Data(bytesNoCopy: base, count: data.count, deallocator: .free)
  }

  public let vertexData: Data

  public let vertexCount: Int

  public let vertexIndices: [UInt32]?

  public let attributeDescriptors: [VertexAttributeDescriptor]

  public let primitiveType: Mesh.PrimitiveType

}
