import CGLFW

/// A collection of vertices, edges and faces that represents a 3D geometry.
public final class Mesh: GraphicsResource {

  /// Initializes a mesh from a mesh source.
  ///
  /// - Parameters:
  ///   - source: The mesh's source.
  public init<Source>(source: Source) where Source: MeshSource {
    // Copy essential source data (i.e., those required by the drawing method).
    self.vertexCount = source.vertexCount
    self.vertexIndices = source.vertexIndices
    self.primitiveType = source.primitiveType

    // Compute the mesh's bounding box from the vertex data.
    if let attribute = source.attributeDescriptors.first(where: { $0.semantic == .position }) {
      assert(attribute.componentType == Float.self)

      var minPoint: Vector3 = Vector3(x: Double(Int.max), y: Double(Int.max), z: Double(Int.max))
      var maxPoint: Vector3 = Vector3(x: Double(Int.min), y: Double(Int.min), z: Double(Int.min))

      source.vertexData.withUnsafeBytes({ buffer in
        for i in stride(
          from: attribute.offset,
          to: attribute.offset + attribute.stride * source.vertexCount,
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

      self.aabb = AxisAlignedBox(origin: minPoint, dimensions: maxPoint - minPoint)
    } else {
      self.aabb = AxisAlignedBox(origin: .zero, dimensions: .zero)
    }

    self.source = source
    self.state = .unloaded
  }

  /// The number of vertices composing the mesh.
  public let vertexCount: Int

  /// The indices of each vertex in the vertex data, used for index drawing if defined.
  public let vertexIndices: [UInt32]?

  /// The drawing type that connect vertices when rendering the mesh.
  public let primitiveType: PrimitiveType

  /// A type of drawing primitive that connects vertices when rendering a mesh.
  public enum PrimitiveType {

    /// A sequence of triangles, each described by three new verticies.
    case triangles

    /// A sequence of lines, each described by two new vertices.
    case lines

    /// A sequence of unconnected points.
    case points

  }

  /// The mesh's axis-aligned bounding box.
  public let aabb: AxisAlignedBox

  // MARK: Internal API

  /// The ID of OpenGL's vertex array.
  private var vaoID: GL.UInt = 0

  /// The ID of OpenGL's element array buffer.
  private var eboID: GL.UInt = 0

  /// The ID of OpenGL's vertex buffer.
  private var vboID: GL.UInt = 0

  /// The data source for this mesh.
  private var source: MeshSource?

  /// Draws the model's meshes.
  ///
  /// This method should be called after the shader used to draw the mesh's vertices been bound.
  internal func draw() {
    assert(state == .loaded)

    // Bind the mesh's vertex array (VAO).
    glBindVertexArray(vaoID)

    // Draw the mesh's vertices.
    if let indices = vertexIndices {
      assert(eboID != 0)
      glDrawElements(
        primitiveType.glValue,
        GL.Size(indices.count),
        GL.Enum(GL_UNSIGNED_INT),
        nil)
    } else {
      glDrawArrays(primitiveType.glValue, 0, GL.Size(vertexCount))
    }

    // Unbind the mesh's buffer.
    glBindVertexArray(0)
    glUseProgram(0)
  }

  var state: GraphicsResourceState

  internal final func load() {
    assert(state != .gone)

    guard state != .loaded
      else { return }

    assert(AppContext.shared.isInitialized)
    assert(glfwGetCurrentContext() != nil)
    assert(source != nil)

    let drawHint = GL.DYNAMIC_DRAW

    // Upload the vertex data into a VAO and VBO.
    glGenVertexArrays(1, &vaoID)
    assert(vaoID != 0)
    glBindVertexArray(vaoID)

    glGenBuffers(1, &vboID)
    assert(vboID != 0)
    glBindBuffer(GL.ARRAY_BUFFER, vboID)

    source!.vertexData.withUnsafeBytes({ buffer in
      glBufferData(GL.ARRAY_BUFFER, buffer.count, buffer.baseAddress, drawHint)
    })

    for descriptor in source!.attributeDescriptors {
      glVertexAttribPointer(
        GL.UInt(descriptor.shaderLocation),
        GL.Int(descriptor.componentCountPerVertex),
        glTypeSymbol(of: descriptor.componentType)!,
        0,
        GL.Size(descriptor.stride),
        UnsafeRawPointer(bitPattern: descriptor.offset))
      glEnableVertexAttribArray(GL.UInt(descriptor.shaderLocation))
    }

    // Upload vertex indices into a EBO, if defined.
    if let indices = source!.vertexIndices {
      glGenBuffers(1, &eboID)
      assert(eboID != 0)
      glBindBuffer(GL.ELEMENT_ARRAY_BUFFER, eboID)
      indices.withUnsafeBufferPointer({ buffer in
        glBufferData(
          GL.ELEMENT_ARRAY_BUFFER,
          buffer.count * MemoryLayout<UInt32>.stride,
          buffer.baseAddress,
          drawHint)
      })
    }

    // Dispose of the data source.
    source = nil

    state = .loaded
    LogManager.main.log(
      "Mesh '\(address(of: self))' successfully loaded (\(vertexCount) vertices).",
      level: .debug)

    // Bind the texture's lifetime to the app context.
    AppContext.shared.graphicsResourceManager.store(self)
  }

  func unload() {
    if vaoID > 0 {
      glDeleteBuffers(2, [vboID, eboID])
      glDeleteVertexArrays(1, &vaoID)
      LogManager.main.log("Mesh '\(address(of: self))' successfully unloaded.", level: .debug)

      vaoID = 0
      vboID = 0
      eboID = 0
    }

    state = .gone
  }

  deinit {
    // Delete the mesh's buffers from the GPU memory.
    glDeleteBuffers(2, [vboID, eboID])
    // glDeleteBuffers(1, &eboID)
    glDeleteVertexArrays(1, &vaoID)
  }

}
