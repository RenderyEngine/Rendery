import Foundation
import Numerics

extension Mesh {

  /// Creates the mesh of a 2x2 rectangle on the xy-plane.
  public static func rectangle() -> Mesh {
    let spec = Rectangle(
      origin: Vector2(x: -1.0, y: -1.0),
      dimensions: Vector2(x: 2.0, y: 2.0))
    return rectangle(spec)
  }

  /// Creates the mesh of a rectangle on the xy-plane with the given specification.
  ///
  /// - Parameter spec: The rectangle's specification.
  public static func rectangle(
    _ spec: Rectangle = Rectangle(x: -1.0, y: -1.0, width: 2.0, height: 2.0)
  ) -> Mesh {
    let (lx, ly) = (Float(spec.minX), Float(spec.minY))
    let (gx, gy) = (Float(spec.maxX), Float(spec.maxY))

    // Create the vertex data of a rectangle with the specified dimensions.
    let vertexData: [Float] = [
      // Positions  // Normals    // UVs
      lx, gy, 0.0,  0.0, 0.0, 1.0,  0.0, 1.0, // top left
      lx, ly, 0.0,  0.0, 0.0, 1.0,  0.0, 0.0, // bottom left
      gx, ly, 0.0,  0.0, 0.0, 1.0,  1.0, 0.0, // bottom right
      gx, gy, 0.0,  0.0, 0.0, 1.0,  1.0, 1.0, // top right
    ]

    // Assign each vertex to its index in the vertex data.
    let vertexIndices: [UInt32] = [0, 1, 2, 0, 2, 3]

    // Generate the mesh.
    return generate(vertexData: vertexData, vertexIndices: vertexIndices)
  }

  /// Creates the mesh of an axis-aligned 2x2x2 box.
  public static func box() -> Mesh {
    let spec = AxisAlignedBox(
      origin: Vector3(x: -1.0, y: -1.0, z: -1.0),
      dimensions: Vector3(x: 2.0, y: 2.0, z: 2.0))
    return box(spec)
  }

  /// Creates the mesh of an axis-aligned box with the specified dimensions.
  ///
  /// - Parameter spec: The box's specification.
  public static func box(_ spec: AxisAlignedBox) -> Mesh {
    let (lx, ly, lz) = (Float(spec.minX), Float(spec.minY), Float(spec.minZ))
    let (gx, gy, gz) = (Float(spec.maxX), Float(spec.maxY), Float(spec.maxZ))

    // Create the vertex data of a cube with the specified dimensions.
    let vertexData: [Float] = [
      // Positions  // Normals        // UVs
      lx, gy, gz,   0.0,  0.0,  1.0,  0.0, 1.0, // front nw
      lx, ly, gz,   0.0,  0.0,  1.0,  0.0, 1.0, // front sw
      gx, ly, gz,   0.0,  0.0,  1.0,  0.0, 1.0, // front se
      gx, gy, gz,   0.0,  0.0,  1.0,  0.0, 1.0, // front ne

      gx, gy, gz,   1.0,  0.0,  0.0,  0.0, 1.0, // right nw
      gx, ly, gz,   1.0,  0.0,  0.0,  0.0, 1.0, // front sw
      gx, ly, lz,   1.0,  0.0,  0.0,  0.0, 1.0, // front se
      gx, gy, lz,   1.0,  0.0,  0.0,  0.0, 1.0, // front ne

      gx, gy, lz,   0.0,  0.0, -1.0,  0.0, 1.0, // back nw
      gx, ly, lz,   0.0,  0.0, -1.0,  0.0, 1.0, // back sw
      lx, ly, lz,   0.0,  0.0, -1.0,  0.0, 1.0, // back se
      lx, gy, lz,   0.0,  0.0, -1.0,  0.0, 1.0, // back ne

      lx, gy, lz,  -1.0,  0.0,  0.0,  0.0, 1.0, // left nw
      lx, ly, lz,  -1.0,  0.0,  0.0,  0.0, 1.0, // left sw
      lx, ly, gz,  -1.0,  0.0,  0.0,  0.0, 1.0, // left ne
      lx, gy, gz,  -1.0,  0.0,  0.0,  0.0, 1.0, // left se

      lx, ly, gz,   0.0, -1.0,  0.0,  0.0, 1.0, // bottom nw
      lx, ly, lz,   0.0, -1.0,  0.0,  0.0, 1.0, // bottom sw
      gx, ly, lz,   0.0, -1.0,  0.0,  0.0, 1.0, // bottom se
      gx, ly, gz,   0.0, -1.0,  0.0,  0.0, 1.0, // bottom ne

      lx, gy, lz,   0.0,  1.0,  0.0,  0.0, 1.0, // top nw
      lx, gy, gz,   0.0,  1.0,  0.0,  0.0, 1.0, // top sw
      gx, gy, gz,   0.0,  1.0,  0.0,  0.0, 1.0, // top se
      gx, gy, lz,   0.0,  1.0,  0.0,  0.0, 1.0, // top ne
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

  /// Creates the mesh that consists of multiple segments connecting the two specified points.
  ///
  /// - Parameters:
  ///   - points: An array of at least two points, specifying the edges of the polyline.
  ///   - thickness: The thickness of the polyline.
  public static func polyline(points: [Vector2], thickness: Double = 0.1) -> Mesh {
    assert(points.count >= 2)

    // Extrude the segments described in `points` to create quads.
    let v0 = points[1] - points[0]
    let u0 = Vector2(x: -v0.y, y: v0.x).normalized * thickness
    var positions = [
      Vector3(x: points[0].x + u0.x, y: points[0].y + u0.y, z: 0.0),
      Vector3(x: points[0].x - u0.x, y: points[0].y - u0.y, z: 0.0),
    ]

    for i in 1 ..< points.count {
      let v = points[i] - points[i - 1]
      var u = Vector2(x: -v.y, y: v.x).normalized * thickness

      // If there is another point after the current one, try to adjust u's position by computing
      // the cross-section with the joint segment to soften the extruded edges. A better solution
      // should probably leverage the geometry shader to deal very sharp corners.
      if i + 1 < points.count {
        let alpha = Angle(from: v, to: points[i + 1] - points[i])
        var theta = alpha + ((.rad(.pi) - alpha) / 2.0)
        if points[i].y > points[i + 1].y {
          theta = -theta
        }

        let cosT = Double.cos(theta.radians)
        let sinT = Double.sin(theta.radians)
        let v2 = Vector2(
          x: v.x * cosT - v.y * sinT,
          y: v.x * sinT + v.y * cosT)
        u = v2.normalized * thickness

        if points[i].y > points[i + 1].y {
          u = -u
        }
      }

      positions.append(contentsOf: [
        Vector3(x: points[i].x + u.x, y: points[i].y + u.y, z: 0.0),
        Vector3(x: points[i].x - u.x, y: points[i].y - u.y, z: 0.0)
      ])
    }

    // Compute vertex indices so that it create quads.
    var indices: [UInt32] = []
    for i in stride(from: 0, to: positions.count - 2, by: 2) {
      indices.append(contentsOf: [
        UInt32(i), UInt32(i + 1), UInt32(i + 3),
        UInt32(i), UInt32(i + 3), UInt32(i + 2),
      ])
    }

    // Generate the vertex data (positions + normals).
    var vertexData: [Float] = []
    for position in positions {
      vertexData.append(contentsOf: [Float(position.x), Float(position.y), 0.0])
      vertexData.append(contentsOf: [0.0, 0.0, 1.0])
    }

    let stride = MemoryLayout<Float>.stride * 6
    let source = MeshData(
      vertexData: vertexData,
      vertexCount: positions.count,
      vertexIndices: indices,
      attributeDescriptors: [
        .position(offset: 0, stride: stride),
        .normal(offset: 3, stride: stride),
      ])

    return Mesh(source: source)
  }

  /// Generates a basic mesh from the specified vertex data.
  ///
  /// - Parameters:
  ///   - vertexData: The mesh's vertex data.
  ///   - vertexIndices: The vertex indices.
  private static func generate(vertexData: [Float], vertexIndices: [UInt32]) -> Mesh {
    let stride = MemoryLayout<Float>.stride * 8
    let source = MeshData(
      vertexData: vertexData,
      vertexCount: vertexData.count / 8,
      vertexIndices: vertexIndices,
      attributeDescriptors: [
        .position(offset: 0, stride: stride),
        .normal(offset: 3 * MemoryLayout<Float>.stride, stride: stride),
        .uv(offset: 6 * MemoryLayout<Float>.stride, stride: stride)
      ])

    // Create and return the mesh.
    return Mesh(source: source)
  }

}
