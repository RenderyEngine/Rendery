/// A structure that represents a 4x4 matrix.
public struct Matrix4 {

  /// Initializes a 4x4 matrix with its components.
  ///
  /// - Parameter components: An array of 16 values representing the matrix' components, in
  ///   row-major order (i.e., the first 4 components represent the matrix's first row).
  public init(components: [Double]) {
    assert(components.count == 16)
    self.components = components
  }

  /// Initializes a translation matrix.
  ///
  /// - Parameter translation: A vector representing the translation along each axis.
  public init(translation: Vector3) {
    self.components = Matrix4.identity.components
    self[0,3] = translation.x
    self[1,3] = translation.y
    self[2,3] = translation.z
  }

  /// Initializes a rotation matrix.
  ///
  /// - Parameter rotation: A quaternion representing the rotation.
  public init(rotation: Quaternion) {
    self.components = rotation.transform.components
  }

  /// Initializes a scaling matrix.
  ///
  /// - Parameter scale: A vector representing the scale factor for each axis.
  public init(scale: Vector3) {
    self.components = Matrix4.identity.components
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
    let q = rotation.transform
    self.init(components: [
      scale.x * q[0,0], // [0,0]
      scale.y * q[0,1], // [0,1]
      scale.z * q[0,2], // [0,2]
      translation.x,    // [0,3]
      scale.x * q[1,0], // [1,0]
      scale.y * q[1,1], // [1,1]
      scale.z * q[1,2], // [1,2]
      translation.y,    // [1,3]
      scale.x * q[2,0], // [2,0]
      scale.y * q[2,1], // [2,1]
      scale.z * q[2,2], // [2,2]
      translation.z,    // [2,3]
      0.0,              // [3,0]
      0.0,              // [3,1]
      0.0,              // [3,2]
      1.0,              // [3,3]
    ])
  }

  /// The matrix' components, in row-major order.
  public private(set) var components: [Double]

  /// Accesses the component identified by the specified row and column.
  ///
  /// - Parameters:
  ///   - row: The component's row.
  ///   - column: The component's column.
  public subscript(row: Int, column: Int) -> Double {
    get { components[row * 4 + column] }
    set { components[row * 4 + column] = newValue }
  }

  /// This matrix, transposed.
  public var transposed: Matrix4 {
    var res = Array<Double>(repeating: 0.0, count: 16)
    for i in 0 ..< 4 {
      res[i +  0] = self[i,0]
      res[i +  4] = self[i,1]
      res[i +  8] = self[i,2]
      res[i + 12] = self[i,3]
    }
    return Matrix4(components: res)
  }

  /// This matrix, inverted.
  public var inverted: Matrix4 {
    // Initialize the result's components.
    var res = Array<Double>(repeating: 0.0, count: 16)

    // Transpose the matrix.
    var src = Array<Double>(repeating: 0.0, count: 16)
    for i in 0 ..< 4 {
      src[i +  0] = self[i,0]
      src[i +  4] = self[i,1]
      src[i +  8] = self[i,2]
      src[i + 12] = self[i,3]
    }

    // Compute pairs for first 8 elements (cofactors).
    var tmp = [
      src[10] * src[15],
      src[11] * src[14],
      src[9]  * src[15],
      src[11] * src[13],
      src[9]  * src[14],
      src[10] * src[13],
      src[8]  * src[15],
      src[11] * src[12],
      src[8]  * src[14],
      src[10] * src[12],
      src[8]  * src[13],
      src[9]  * src[12],
    ]

    // Compute the 8 first elements (cofactors).
    res[0] = (tmp[0] * src[5] + tmp[3] * src[6] + tmp[4]  * src[7]) -
             (tmp[1] * src[5] + tmp[2] * src[6] + tmp[5]  * src[7])
    res[1] = (tmp[1] * src[4] + tmp[6] * src[6] + tmp[9]  * src[7]) -
             (tmp[0] * src[4] + tmp[7] * src[6] + tmp[8]  * src[7])
    res[2] = (tmp[2] * src[4] + tmp[7] * src[5] + tmp[10] * src[7]) -
             (tmp[3] * src[4] + tmp[6] * src[5] + tmp[11] * src[7])
    res[3] = (tmp[5] * src[4] + tmp[8] * src[5] + tmp[11] * src[6]) -
             (tmp[4] * src[4] + tmp[9] * src[5] + tmp[10] * src[6])
    res[4] = (tmp[1] * src[1] + tmp[2] * src[2] + tmp[5]  * src[3]) -
             (tmp[0] * src[1] + tmp[3] * src[2] + tmp[4]  * src[3])
    res[5] = (tmp[0] * src[0] + tmp[7] * src[2] + tmp[8]  * src[3]) -
             (tmp[1] * src[0] + tmp[6] * src[2] + tmp[9]  * src[3])
    res[6] = (tmp[3] * src[0] + tmp[6] * src[1] + tmp[11] * src[3]) -
             (tmp[2] * src[0] + tmp[7] * src[1] + tmp[10] * src[3])
    res[7] = (tmp[4] * src[0] + tmp[9] * src[1] + tmp[10] * src[2]) -
             (tmp[5] * src[0] + tmp[8] * src[1] + tmp[11] * src[2])

    // Compute pairs for next 8 elements (cofactors).
    tmp[0]  = src[2] * src[7]
    tmp[1]  = src[3] * src[6]
    tmp[2]  = src[1] * src[7]
    tmp[3]  = src[3] * src[5]
    tmp[4]  = src[1] * src[6]
    tmp[5]  = src[2] * src[5]
    tmp[6]  = src[0] * src[7]
    tmp[7]  = src[3] * src[4]
    tmp[8]  = src[0] * src[6]
    tmp[9]  = src[2] * src[4]
    tmp[10] = src[0] * src[5]
    tmp[11] = src[1] * src[4]

    // Compute the 8 next elements (cofactors)
    res[8]  = (tmp[0]  * src[13] + tmp[3]  * src[14] + tmp[4]  * src[15]) -
              (tmp[1]  * src[13] + tmp[2]  * src[14] + tmp[5]  * src[15])
    res[9]  = (tmp[1]  * src[12] + tmp[6]  * src[14] + tmp[9]  * src[15]) -
              (tmp[0]  * src[12] + tmp[7]  * src[14] + tmp[8]  * src[15])
    res[10] = (tmp[2]  * src[12] + tmp[7]  * src[13] + tmp[10] * src[15]) -
              (tmp[3]  * src[12] + tmp[6]  * src[13] + tmp[11] * src[15])
    res[11] = (tmp[5]  * src[12] + tmp[8]  * src[13] + tmp[11] * src[14]) -
              (tmp[4]  * src[12] + tmp[9]  * src[13] + tmp[10] * src[14])
    res[12] = (tmp[2]  * src[10] + tmp[5]  * src[11] + tmp[1]  * src[9]) -
              (tmp[4]  * src[11] + tmp[0]  * src[9]  + tmp[3]  * src[10])
    res[13] = (tmp[8]  * src[11] + tmp[0]  * src[8]  + tmp[7]  * src[10]) -
              (tmp[6]  * src[10] + tmp[9]  * src[11] + tmp[1]  * src[8])
    res[14] = (tmp[6]  * src[9]  + tmp[11] * src[11] + tmp[3]  * src[8]) -
              (tmp[10] * src[11] + tmp[2]  * src[8]  + tmp[7]  * src[9])
    res[15] = (tmp[10] * src[10] + tmp[4]  * src[8]  + tmp[9]  * src[9]) -
              (tmp[8]  * src[9]  + tmp[11] * src[10] + tmp[5]  * src[8])

    // Compute the determinant (no solution if det = 0).
    let det = src[0] * res[0] + src[1] * res[1] + src[2] * res[2] + src[3] * res[3]
    let invDet = 1.0 / det

    return Matrix4(components: res.map({ $0 * invDet }))
  }

  /// Decomposes the matrix into a scale factor, a rotation and a translation.
  public func decompose() -> (translation: Vector3, rotation: Quaternion, scale: Vector3) {

    // This decomposition method relies on the fact that the matrix may only encode scale, rotation
    // and/or orientation, and that each scale component is positive. It won't produce correct
    // results otherwise.
    // A more accurate implementation can be found in Ogre3D's source, which relies on a QR
    // decomposition to extract rotation, scaling and shear. Another solution suggested on
    // stackexchange uses polar decomposition: https://math.stackexchange.com/questions/237369

    var comp = components

    // Extract the translation.
    let translation = Vector3(x: comp[3], y: comp[7], z: comp[11])

    // Extract the scale.
    let sx = Vector3(x: comp[0], y: comp[4], z: comp[8]).magnitude
    let sy = Vector3(x: comp[1], y: comp[5], z: comp[9]).magnitude
    let sz = Vector3(x: comp[2], y: comp[6], z: comp[10]).magnitude
    let scale = Vector3(x: sx, y: sy, z: sz)

    // Extract the rotation.
    comp[0] = comp[0] / sx
    comp[1] = comp[1] / sy
    comp[2] = comp[2] / sz
    comp[3] = 0.0
    comp[4] = comp[4] / sx
    comp[5] = comp[5] / sy
    comp[6] = comp[6] / sz
    comp[7] = 0.0
    comp[8] = comp[8] / sx
    comp[9] = comp[9] / sy
    comp[10] = comp[10] / sz
    comp[11] = 0.0
    let rotation = Quaternion(matrix: Matrix4(components: comp))

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
    return Matrix4(components: [
      m[0,0] * n[0,0] + m[0,1] * n[1,0] + m[0,2] * n[2,0] + m[0,3] * n[3,0],
      m[0,0] * n[0,1] + m[0,1] * n[1,1] + m[0,2] * n[2,1] + m[0,3] * n[3,1],
      m[0,0] * n[0,2] + m[0,1] * n[1,2] + m[0,2] * n[2,2] + m[0,3] * n[3,2],
      m[0,0] * n[0,3] + m[0,1] * n[1,3] + m[0,2] * n[2,3] + m[0,3] * n[3,3],
      m[1,0] * n[0,0] + m[1,1] * n[1,0] + m[1,2] * n[2,0] + m[1,3] * n[3,0],
      m[1,0] * n[0,1] + m[1,1] * n[1,1] + m[1,2] * n[2,1] + m[1,3] * n[3,1],
      m[1,0] * n[0,2] + m[1,1] * n[1,2] + m[1,2] * n[2,2] + m[1,3] * n[3,2],
      m[1,0] * n[0,3] + m[1,1] * n[1,3] + m[1,2] * n[2,3] + m[1,3] * n[3,3],
      m[2,0] * n[0,0] + m[2,1] * n[1,0] + m[2,2] * n[2,0] + m[2,3] * n[3,0],
      m[2,0] * n[0,1] + m[2,1] * n[1,1] + m[2,2] * n[2,1] + m[2,3] * n[3,1],
      m[2,0] * n[0,2] + m[2,1] * n[1,2] + m[2,2] * n[2,2] + m[2,3] * n[3,2],
      m[2,0] * n[0,3] + m[2,1] * n[1,3] + m[2,2] * n[2,3] + m[2,3] * n[3,3],
      m[3,0] * n[0,0] + m[3,1] * n[1,0] + m[3,2] * n[2,0] + m[3,3] * n[3,0],
      m[3,0] * n[0,1] + m[3,1] * n[1,1] + m[3,2] * n[2,1] + m[3,3] * n[3,1],
      m[3,0] * n[0,2] + m[3,1] * n[1,2] + m[3,2] * n[2,2] + m[3,3] * n[3,2],
      m[3,0] * n[0,3] + m[3,1] * n[1,3] + m[3,2] * n[2,3] + m[3,3] * n[3,3],
    ])
  }

  /// Returns the transformation of a quaternion by a matrix.
  ///
  /// - Parameters:
  ///   - m: A transformation matrix.
  ///   - q: The quaternion to transform.
  public static func * (m: Matrix4, q: Quaternion) -> Quaternion {
    return Quaternion(
      w: m[0,3] * q.x + m[1,3] * q.y + m[2,3] * q.z + m[3,3] * q.w,
      x: m[0,0] * q.x + m[1,0] * q.y + m[2,0] * q.z + m[3,0] * q.w,
      y: m[0,1] * q.x + m[1,1] * q.y + m[2,1] * q.z + m[3,1] * q.w,
      z: m[0,2] * q.x + m[1,2] * q.y + m[2,2] * q.z + m[3,2] * q.w)
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

  /// Initializes a "look at" view matrix.
  ///
  /// - Parameters:
  ///   - origin: The position of the observer (typically the camera's position).
  ///   - target: The position of the target point.
  ///   - up: A normalized up vector specifying how the observer is oriented.
  public static func lookAt(
    from origin: Vector3,
    to target: Vector3,
    up: Vector3 = .unitY
  ) -> Matrix4 {
    let d = (origin - target).normalized
    let r = up.cross(d)
    let u = d.cross(r)

    return Matrix4(components: [
      r.x, r.y, r.z, -r.dot(origin),
      u.x, u.y, u.z, -u.dot(origin),
      d.x, d.y, d.z, -d.dot(origin),
      0.0, 0.0, 0.0, 1.0,
    ])
  }

  /// The matrix whose all components are zero.
  public static var zero: Matrix4 {
    return Matrix4(components: Array(repeating: 0.0, count: 16))
  }

  /// The 3D transformation matrix representing the identity.
  public static var identity: Matrix4 {
    return Matrix4(components: [
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0,
    ])
  }

}
