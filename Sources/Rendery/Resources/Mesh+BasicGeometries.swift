import Foundation

extension Mesh {

  /// Creates the mesh of a flat rectangle with the given specification.
  ///
  /// - Parameter spec: The rectangle's specification.
  public static func rectangle(
    _ spec: Rectangle = Rectangle(x: -1.0, y: -1.0, width: 2.0, height: 2.0)
  ) -> Mesh {
    let (lx, ly) = (Float(spec.minX), Float(spec.minY))
    let (gx, gy) = (Float(spec.maxX), Float(spec.maxY))

    // Create the vertex data of a rectangle with the specified dimensions.
    let vertexData: [Float] = [
      // Positions  // Texcoords  // Normals
      lx, gy, 0.0,  0.0, 1.0,     0.0, 0.0, 1.0, // top left
      lx, ly, 0.0,  0.0, 0.0,     0.0, 0.0, 1.0, // bottom left
      gx, ly, 0.0,  1.0, 0.0,     0.0, 0.0, 1.0, // bottom right
      gx, gy, 0.0,  1.0, 1.0,     0.0, 0.0, 1.0, // top right
    ]

    // Assign each vertex to its index in the vertex data.
    let vertexIndices: [UInt32] = [0, 1, 2, 0, 2, 3]

    // Generate the mesh.
    return generate(vertexData: vertexData, vertexIndices: vertexIndices)
  }

  /// Creates the mesh of a box with the specified dimensions.
  ///
  /// - Parameter spec: The box' specification.
  public static func box(
    _ spec: Box = Box(x: -1.0, y: -1.0, z: -1.0, width: 2.0, height: 2.0, depth: 2.0)
  ) -> Mesh {
    let (lx, ly, lz) = (Float(spec.minX), Float(spec.minY), Float(spec.minZ))
    let (gx, gy, gz) = (Float(spec.maxX), Float(spec.maxY), Float(spec.maxZ))

    // Create the vertex data of a cube with the specified dimensions.
    let vertexData: [Float] = [
      // Positions  // Texcoords  // Normals
      lx, gy, gz,   0.0, 1.0,      0.0,  0.0,  1.0, // front nw
      lx, ly, gz,   0.0, 1.0,      0.0,  0.0,  1.0, // front sw
      gx, ly, gz,   0.0, 1.0,      0.0,  0.0,  1.0, // front se
      gx, gy, gz,   0.0, 1.0,      0.0,  0.0,  1.0, // front ne

      gx, gy, gz,   0.0, 1.0,      1.0,  0.0,  0.0, // right nw
      gx, ly, gz,   0.0, 1.0,      1.0,  0.0,  0.0, // front sw
      gx, ly, lz,   0.0, 1.0,      1.0,  0.0,  0.0, // front se
      gx, gy, lz,   0.0, 1.0,      1.0,  0.0,  0.0, // front ne

      gx, gy, lz,   0.0, 1.0,      0.0,  0.0, -1.0, // back nw
      gx, ly, lz,   0.0, 1.0,      0.0,  0.0, -1.0, // back sw
      lx, ly, lz,   0.0, 1.0,      0.0,  0.0, -1.0, // back se
      lx, gy, lz,   0.0, 1.0,      0.0,  0.0, -1.0, // back ne

      lx, gy, lz,   0.0, 1.0,     -1.0,  0.0,  0.0, // left nw
      lx, ly, lz,   0.0, 1.0,     -1.0,  0.0,  0.0, // left sw
      lx, ly, gz,   0.0, 1.0,     -0.0,  0.0,  0.0, // left ne
      lx, gy, gz,   0.0, 1.0,     -0.0,  0.0,  0.0, // left se

      lx, ly, gz,   0.0, 1.0,      0.0, -1.0,  0.0, // bottom nw
      lx, ly, lz,   0.0, 1.0,      0.0, -1.0,  0.0, // bottom sw
      gx, ly, lz,   0.0, 1.0,      0.0, -1.0,  0.0, // bottom se
      gx, ly, gz,   0.0, 1.0,      0.0, -1.0,  0.0, // bottom ne

      lx, gy, lz,   0.0, 1.0,      0.0,  1.0,  0.0, // top nw
      lx, gy, gz,   0.0, 1.0,      0.0,  1.0,  0.0, // top sw
      gx, gy, gz,   0.0, 1.0,      0.0,  1.0,  0.0, // top se
      gx, gy, lz,   0.0, 1.0,      0.0,  1.0,  0.0, // top ne
    ]

    // Assign each vertex to its index in the vertex data.
    let vertexIndices: [UInt32] = [
      0, 1, 2, 0, 2, 3,
      4, 5, 6, 4, 6, 7,
      8, 9, 10, 8, 10, 11,
      12, 13, 14, 12, 14, 15,
      16, 17, 18, 16, 18, 19,
      20, 21, 22, 20, 22, 23,
    ]

    // Generate the mesh.
    return generate(vertexData: vertexData, vertexIndices: vertexIndices)
  }

  /// Generates a basic mesh from the specified vertex data.
  ///
  /// - Parameters:
  ///   - vertexData: The mesh's vertex data.
  ///   - vertexIndices: The vertex indices.
  private static func generate(vertexData: [Float], vertexIndices: [UInt32]) -> Mesh {
    // Define the attribute descriptors of the vertex data.
    let stride = MemoryLayout<Float>.stride * 8
    let positions = VertexAttributeDescriptor(
      offset: 0,
      stride: stride,
      semantic: .position,
      componentCountPerVertex: 3,
      componentType: Float.self,
      shaderLocation: 0)

    let texcoords = VertexAttributeDescriptor(
      offset: 3 * MemoryLayout<Float>.stride,
      stride: stride,
      semantic: .textureCoordinates,
      componentCountPerVertex: 2,
      componentType: Float.self,
      shaderLocation: 1)

    let normals = VertexAttributeDescriptor(
      offset: 5 * MemoryLayout<Float>.stride,
      stride: stride,
      semantic: .normal,
      componentCountPerVertex: 3,
      componentType: Float.self,
      shaderLocation: 2)

    // Generate a mesh source with the vertex data.
    let meshSource = vertexData.withUnsafeBufferPointer({ buffer in
      MeshData(
        vertexData: Data(buffer: buffer),
        vertexCount: vertexData.count / 8,
        vertexIndices: vertexIndices,
        attributeDescriptors: [positions, texcoords, normals])
    })

    // Create and return the mesh.
    return Mesh(source: meshSource)
  }

}
