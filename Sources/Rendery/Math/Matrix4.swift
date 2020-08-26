/// A structure that represents a 4x4 matrix.
///
/// Memory layout:
/// --------------
///
/// Rendery adopt OpenGL's default memory layout to represent matrices. A 4x4 matrix is represented
/// by 16 values laid out contiguously in memory, each consecutive set of 4 values representing one
/// of the matrix's columns. This memory layout, often dubbed a _column-major_ order.
///
/// For 4x4 transformation matrices, this layout implies that the translation components occupy the
/// 12th, 13th and 14th positions in the matrix's contiguous memory, assuming 0-based indices.
public struct Matrix4: Hashable {

  /// Initializes a 4x4 matrix with its components.
  ///
  /// - Parameter components: An array of 16 values representing the matrix' components, in
  ///   __column-major order__ (i.e., the first 4 components represent the matrix's first column).
  private init(columnMajor components: [Double]) {
    assert(components.count == 16)
    self.components = components
  }

  /// Initializes a translation matrix.
  ///
  /// A (column-major) 4x4 translation matrix encodes the translation values `x` `y` and `z` on its
  /// 4th column:
  ///
  /// ```plain
  /// | 1 0 0 x |
  /// | 0 1 0 y |
  /// | 0 0 1 z |
  /// | 0 0 0 1 |
  /// ```
  ///
  /// - Parameter translation: A vector representing the translation along each axis.
  public init(translation: Vector3) {
    self = Matrix4.identity
    self[0,3] = translation.x
    self[1,3] = translation.y
    self[2,3] = translation.z
  }

  /// Initializes a rotation matrix.
  ///
  /// - Parameter rotation: A quaternion representing the rotation.
  public init(rotation: Quaternion) {
    self = rotation.transform
  }

  /// Initializes a scaling matrix.
  ///
  /// A 4x4 scaling matrix encodes the scale factors `x` `y` and `z` on its diagonal:
  ///
  /// ```plain
  /// | x 0 0 0 |
  /// | 0 y 0 0 |
  /// | 0 0 z 0 |
  /// | 0 0 0 1 |
  /// ```
  ///
  /// - Parameter scale: A vector representing the scale factor for each axis.
  public init(scale: Vector3) {
    self = Matrix4.identity
    self[0,0] = scale.x
    self[1,1] = scale.y
    self[2,2] = scale.z
  }

  /// Initializes a transformation matrix from a translation, a rotation and a scale factor.
  ///
  /// - Parameters:
  ///   - translation: A vector representing the translation along each axis.
  ///   - rotation: A quaternion representing the rotation.
  ///   - scale: A vector representing the scale factor for each axis.
  public init(translation: Vector3, rotation: Quaternion, scale: Vector3) {
    // Compute the matrix encoding the specified rotation.
    let q = rotation.transform

    // Combine the rotation matrix with the specified translation and scale factor.
    self = Matrix4.identity

    self[0,0] = scale.x * q[0,0]
    self[0,1] = scale.y * q[0,1]
    self[0,2] = scale.z * q[0,2]
    self[0,3] = translation.x

    self[1,0] = scale.x * q[1,0]
    self[1,1] = scale.y * q[1,1]
    self[1,2] = scale.z * q[1,2]
    self[1,3] = translation.y

    self[2,0] = scale.x * q[2,0]
    self[2,1] = scale.y * q[2,1]
    self[2,2] = scale.z * q[2,2]
    self[2,3] = translation.z
  }

  /// The matrix' components, in row-major order.
  public private(set) var components: [Double]

  /// Accesses the component identified by the specified row and column.
  ///
  /// - Parameters:
  ///   - row: The component's row.
  ///   - column: The component's column.
  public subscript(row: Int, column: Int) -> Double {
    get { components[row + 4 * column] }
    set { components[row + 4 * column] = newValue }
  }

  /// This matrix, transposed.
  public var transposed: Matrix4 {
    var res = Matrix4.zero
    for i in 0 ..< 4 {
      res[0,i] = self[i,0]
      res[1,i] = self[i,1]
      res[2,i] = self[i,2]
      res[3,i] = self[i,3]
    }
    return res
  }

  /// The matrix's determinant.
  public var determinant: Double {
    let a = self[0,0] * minor(1, 2, 3, 1, 2, 3)
    let b = self[0,1] * minor(1, 2, 3, 0, 2, 3)
    let c = self[0,2] * minor(1, 2, 3, 0, 1, 3)
    let d = self[0,3] * minor(1, 2, 3, 0, 1, 2)
    return a - b + c - d
  }

  private func minor(_ r0: Int, _ r1: Int, _ r2: Int, _ c0: Int, _ c1: Int, _ c2: Int) -> Double {
    let a = self[r0,c0] * (self[r1,c1] * self[r2,c2] - self[r2,c1] * self[r1,c2])
    let b = self[r0,c1] * (self[r1,c0] * self[r2,c2] - self[r2,c0] * self[r1,c2])
    let c = self[r0,c2] * (self[r1,c0] * self[r2,c1] - self[r2,c0] * self[r1,c1])
    return a - b + c
  }

  /// This matrix, inverted.
  public var inverted: Matrix4 {
    var result = Matrix4.zero

    var v0 = self[2,0] * self[3,1] - self[2,1] * self[3,0]
    var v1 = self[2,0] * self[3,2] - self[2,2] * self[3,0]
    var v2 = self[2,0] * self[3,3] - self[2,3] * self[3,0]
    var v3 = self[2,1] * self[3,2] - self[2,2] * self[3,1]
    var v4 = self[2,1] * self[3,3] - self[2,3] * self[3,1]
    var v5 = self[2,2] * self[3,3] - self[2,3] * self[3,2]

    let t00 =  (v5 * self[1,1] - v4 * self[1,2] + v3 * self[1,3])
    let t10 = -(v5 * self[1,0] - v2 * self[1,2] + v1 * self[1,3])
    let t20 =  (v4 * self[1,0] - v2 * self[1,1] + v0 * self[1,3])
    let t30 = -(v3 * self[1,0] - v1 * self[1,1] + v0 * self[1,2])

    let invDet = 1.0 / (t00 * self[0,0] + t10 * self[0,1] + t20 * self[0,2] + t30 * self[0,3])

    result[0,0] = t00 * invDet
    result[1,0] = t10 * invDet
    result[2,0] = t20 * invDet
    result[3,0] = t30 * invDet

    result[0,1] = -(v5 * self[0,1] - v4 * self[0,2] + v3 * self[0,3]) * invDet
    result[1,1] =  (v5 * self[0,0] - v2 * self[0,2] + v1 * self[0,3]) * invDet
    result[2,1] = -(v4 * self[0,0] - v2 * self[0,1] + v0 * self[0,3]) * invDet
    result[3,1] =  (v3 * self[0,0] - v1 * self[0,1] + v0 * self[0,2]) * invDet

    v0 = self[1,0] * self[3,1] - self[1,1] * self[3,0]
    v1 = self[1,0] * self[3,2] - self[1,2] * self[3,0]
    v2 = self[1,0] * self[3,3] - self[1,3] * self[3,0]
    v3 = self[1,1] * self[3,2] - self[1,2] * self[3,1]
    v4 = self[1,1] * self[3,3] - self[1,3] * self[3,1]
    v5 = self[1,2] * self[3,3] - self[1,3] * self[3,2]

    result[0,2] =  (v5 * self[0,1] - v4 * self[0,2] + v3 * self[0,3]) * invDet
    result[1,2] = -(v5 * self[0,0] - v2 * self[0,2] + v1 * self[0,3]) * invDet
    result[2,2] =  (v4 * self[0,0] - v2 * self[0,1] + v0 * self[0,3]) * invDet
    result[3,2] = -(v3 * self[0,0] - v1 * self[0,1] + v0 * self[0,2]) * invDet

    v0 = self[2,1] * self[1,0] - self[2,0] * self[1,1]
    v1 = self[2,2] * self[1,0] - self[2,0] * self[1,2]
    v2 = self[2,3] * self[1,0] - self[2,0] * self[1,3]
    v3 = self[2,2] * self[1,1] - self[2,1] * self[1,2]
    v4 = self[2,3] * self[1,1] - self[2,1] * self[1,3]
    v5 = self[2,3] * self[1,2] - self[2,2] * self[1,3]

    result[0,3] = -(v5 * self[0,1] - v4 * self[0,2] + v3 * self[0,3]) * invDet
    result[1,3] =  (v5 * self[0,0] - v2 * self[0,2] + v1 * self[0,3]) * invDet
    result[2,3] = -(v4 * self[0,0] - v2 * self[0,1] + v0 * self[0,3]) * invDet
    result[3,3] =  (v3 * self[0,0] - v1 * self[0,1] + v0 * self[0,2]) * invDet

    return result
  }

  /// Decomposes the matrix into a scale factor, a rotation and a translation.
  public func decompose() -> (translation: Vector3, rotation: Quaternion, scale: Vector3) {

    // A likely more accurate implementation can be found in Ogre3D's source, which relies on a QR
    // decomposition to extract rotation, scaling and shear. Another solution suggested on
    // stackexchange uses polar decomposition: https://math.stackexchange.com/questions/237369

    // Extract the translation.
    let translation = Vector3(x: self[0,3], y: self[1,3], z: self[2,3])

    // Extract the scale.
    var sx = Vector3(x: self[0,0], y: self[1,0], z: self[2,0]).magnitude
    let sy = Vector3(x: self[0,1], y: self[1,1], z: self[2,1]).magnitude
    let sz = Vector3(x: self[0,2], y: self[1,2], z: self[2,2]).magnitude
    let scale = Vector3(x: sx, y: sy, z: sz)

    // Invert one scale if the matrix's determinant is negative.
    if determinant < 0.0 {
      sx = -sx
    }

    // Extract the rotation.
    let rotation = Quaternion(matrix: Matrix4(columnMajor: [
      self[0,0] / sx,
      self[1,0] / sx,
      self[2,0] / sx,
      0.0,
      self[0,1] / sy,
      self[1,1] / sy,
      self[2,1] / sy,
      0.0,
      self[0,2] / sz,
      self[1,2] / sz,
      self[2,2] / sz,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ]))

    return (translation, rotation, scale)
  }

  /// Returns the multiplication of two matrices.
  ///
  /// If `m` and `n` are transformation matrices, then their multiplication is the composition
  /// (a.k.a. concatenation) of the transformations they represent.
  ///
  /// This operation is not commutative. In other words, there are pairs of matrices for which
  /// `m * n != n * m`. Consequently, you should be careful of the operands' order.
  ///
  /// - Parameters:
  ///   - m: The first matrix to multiply.
  ///   - n: The second matrix to multiply.
  public static func * (m: Matrix4, n: Matrix4) -> Matrix4 {
    var result = Matrix4.zero

    result[0,0] = m[0,0] * n[0,0] + m[0,1] * n[1,0] + m[0,2] * n[2,0] + m[0,3] * n[3,0]
    result[0,1] = m[0,0] * n[0,1] + m[0,1] * n[1,1] + m[0,2] * n[2,1] + m[0,3] * n[3,1]
    result[0,2] = m[0,0] * n[0,2] + m[0,1] * n[1,2] + m[0,2] * n[2,2] + m[0,3] * n[3,2]
    result[0,3] = m[0,0] * n[0,3] + m[0,1] * n[1,3] + m[0,2] * n[2,3] + m[0,3] * n[3,3]

    result[1,0] = m[1,0] * n[0,0] + m[1,1] * n[1,0] + m[1,2] * n[2,0] + m[1,3] * n[3,0]
    result[1,1] = m[1,0] * n[0,1] + m[1,1] * n[1,1] + m[1,2] * n[2,1] + m[1,3] * n[3,1]
    result[1,2] = m[1,0] * n[0,2] + m[1,1] * n[1,2] + m[1,2] * n[2,2] + m[1,3] * n[3,2]
    result[1,3] = m[1,0] * n[0,3] + m[1,1] * n[1,3] + m[1,2] * n[2,3] + m[1,3] * n[3,3]

    result[2,0] = m[2,0] * n[0,0] + m[2,1] * n[1,0] + m[2,2] * n[2,0] + m[2,3] * n[3,0]
    result[2,1] = m[2,0] * n[0,1] + m[2,1] * n[1,1] + m[2,2] * n[2,1] + m[2,3] * n[3,1]
    result[2,2] = m[2,0] * n[0,2] + m[2,1] * n[1,2] + m[2,2] * n[2,2] + m[2,3] * n[3,2]
    result[2,3] = m[2,0] * n[0,3] + m[2,1] * n[1,3] + m[2,2] * n[2,3] + m[2,3] * n[3,3]

    result[3,0] = m[3,0] * n[0,0] + m[3,1] * n[1,0] + m[3,2] * n[2,0] + m[3,3] * n[3,0]
    result[3,1] = m[3,0] * n[0,1] + m[3,1] * n[1,1] + m[3,2] * n[2,1] + m[3,3] * n[3,1]
    result[3,2] = m[3,0] * n[0,2] + m[3,1] * n[1,2] + m[3,2] * n[2,2] + m[3,3] * n[3,2]
    result[3,3] = m[3,0] * n[0,3] + m[3,1] * n[1,3] + m[3,2] * n[2,3] + m[3,3] * n[3,3]

    return result
  }

  /// Returns the transformation of a vector by a matrix.
  ///
  /// - Parameters:
  ///   - m: A transformation matrix.
  ///   - v: The vector to transform.
  public static func * (m: Matrix4, v: Vector3) -> Vector3 {
    let iw = 1.0 / (m[3,0] * v.x + m[3,1] * v.y + m[3,2] * v.z + m[3,3])
    return Vector3(
      x: (m[0,0] * v.x + m[0,1] * v.y + m[0,2] * v.z + m[0,3]) * iw,
      y: (m[1,0] * v.x + m[1,1] * v.y + m[1,2] * v.z + m[1,3]) * iw,
      z: (m[2,0] * v.x + m[2,1] * v.y + m[2,2] * v.z + m[2,3]) * iw)
  }

  /// Returns the transofmration of a triangle by a matrix.
  ///
  /// - Parameters:
  ///   - m: A transformation matrix.
  ///   - t: The triangle to transform.
  public static func * (m: Matrix4, t: Triangle) -> Triangle {
    return Triangle(a: m * t.a, b: m * t.b, c: m * t.c)
  }

  /// Initializes a "look at" matrix.
  ///
  /// A "look at" matrix is a transformation matrix that can be used to orient and position an
  /// object so that it "looks at" a given point.
  ///
  /// The "look at" matrix is __not__ the same as the view matrix. A view matrix transforms an
  /// object into the camera space, effectively "moving" everything in front of a virtual camera.
  /// It can be obtained by inverting a "look at" matrix.
  ///
  ///     let cameraPosition = Vector3(x: 6.0, y: 0.0, z: 0.0)
  ///     let viewMatrix = Matrix3.lookAt(from: cameraPosition, to: .zero).inverted
  ///
  /// - Parameters:
  ///   - eye: The position of the observer (e.g., the camera's position).
  ///   - target: The position of the target point.
  ///   - up: A normalized up vector specifying how the observer is oriented.
  public static func lookAt(
    from eye: Vector3,
    to target: Vector3,
    up: Vector3 = .unitY
  ) -> Matrix4 {
    var z = (eye - target)
    if z.squaredMagnitude == 0.0 {
      // The origin and the target are in the same position.
      z.z = 1.0
    }

    z = z.normalized
    var x = up.cross(z)

    if x.squaredMagnitude == 0.0 {
      // `up` and `z` are parallel.
      if abs(up.z) == 1.0 {
        z.x += 0.0001
      } else {
        z.x -= 0.0001
      }
      z = z.normalized
      x = up.cross(z)
    }

    x = x.normalized
    let y = z.cross(x).normalized

    var result = Matrix4.zero

    result[0,0] = x.x
    result[1,0] = x.y
    result[2,0] = x.z

    result[0,1] = y.x
    result[1,1] = y.y
    result[2,1] = y.z

    result[0,2] = z.x
    result[1,2] = z.y
    result[2,2] = z.z

    result[0,3] = eye.x
    result[1,3] = eye.y
    result[2,3] = eye.z
    result[3,3] = 1.0

    return result
  }

  /// Initializes a perspective projection matrix.
  ///
  /// - Parameters:
  ///   - top: The top screen coordinate.
  ///   - bottom: The bottom screen coordinate.
  ///   - right: The right screen coordinate.
  ///   - left: The left screen coordinate.
  ///   - far: The distance to the far plane.
  ///   - near: The distance to the near plane.
  public static func perspective(
    top   : Double,
    bottom: Double,
    right : Double,
    left  : Double,
    far   : Double,
    near  : Double
  ) -> Matrix4 {
    var result = Matrix4.zero

    result[0,0] = (2.0 * near) / (right - left)
    result[0,3] = (right + left) / (right - left)
    result[1,1] = (2.0 * near) / (top - bottom)
    result[1,2] = (top + bottom) / (top - bottom)
    result[2,2] = -(far + near) / (far - near)
    result[2,3] = (-2.0 * far * near) / (far - near)
    result[3,2] = -1.0

    return result
  }

  /// Initializes an orthographic projection matrix.
  ///
  /// - Parameters:
  ///   - top: The top screen coordinate.
  ///   - bottom: The bottom screen coordinate.
  ///   - right: The right screen coordinate.
  ///   - left: The left screen coordinate.
  ///   - far: The distance to the far plane.
  ///   - near: The distance to the near plane.
  public static func orthographic(
    top   : Double,
    bottom: Double,
    right : Double,
    left  : Double,
    far   : Double,
    near  : Double
  ) -> Matrix4 {
    var result = Matrix4.zero

    result[0,0] = 2.0 / (right - left)
    result[0,3] = -(right + left) / (right - left)
    result[1,1] = 2.0 / (top - bottom)
    result[1,3] = -(top + bottom) / (top - bottom)
    result[2,2] = -2.0 / (far - near)
    result[2,3] = -(far + near) / (far - near);
    result[3,3] = 1.0

    return result
  }

  /// The matrix whose all components are zero.
  public static var zero: Matrix4 {
    return Matrix4(columnMajor: Array(repeating: 0.0, count: 16))
  }

  /// The 3D transformation matrix representing the identity.
  public static var identity: Matrix4 {
    return Matrix4(columnMajor: [
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0,
    ])
  }

}
