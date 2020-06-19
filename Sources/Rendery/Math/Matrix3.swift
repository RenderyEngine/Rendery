/// A structure that represents a 3x3 matrix.
public struct Matrix3 {

  /// Initializes a 3x3 matrix with its components.
  ///
  /// - Parameter components: An array of 9 values representing the matrix' components, in
  ///   __column-major order__ (i.e., the first 3 components represent the matrix's first column).
  private init(columnMajor components: [Double]) {
    assert(components.count == 9)
    self.components = components
  }

  /// Initializes a 3x3 matrix by extracting the upper-left part of the specified 4x4 matrix.
  ///
  /// - Parameter matrix4: A 4x4 matrix.
  public init(upperLeftOf matrix4: Matrix4) {
    self.components = Array(
      matrix4.components[0 ... 2] + matrix4.components[4 ... 6] + matrix4.components[8 ... 10])
  }

  /// The matrix' components, in column-major order.
  public private(set) var components: [Double]

  /// Accesses the component identified by the specified row and column.
  ///
  /// - Parameters:
  ///   - row: The component's row.
  ///   - column: The component's column.
  public subscript(row: Int, column: Int) -> Double {
    get { components[row + 3 * column] }
    set { components[row + 3 * column] = newValue }
  }

  /// This matrix, transposed.
  public var transposed: Matrix3 {
    var res = Matrix3.zero
    for i in 0 ..< 3 {
      res[0,i] = self[i,0]
      res[1,i] = self[i,1]
      res[2,i] = self[i,2]
    }
    return res
  }

  /// This matrix, inverted.
  public var inverted: Matrix3 {
    var result: Matrix3 = .zero

    result[0,0] = self[1,1] * self[2,2] - self[1,2] * self[2,1]
    result[0,1] = self[0,2] * self[2,1] - self[0,1] * self[2,2]
    result[0,2] = self[0,1] * self[1,2] - self[0,2] * self[1,1]
    result[1,0] = self[1,2] * self[2,0] - self[1,0] * self[2,2]
    result[1,1] = self[0,0] * self[2,2] - self[0,2] * self[2,0]
    result[1,2] = self[0,2] * self[1,0] - self[0,0] * self[1,2]
    result[2,0] = self[1,0] * self[2,1] - self[1,1] * self[2,0]
    result[2,1] = self[0,1] * self[2,0] - self[0,0] * self[2,1]
    result[2,2] = self[0,0] * self[1,1] - self[0,1] * self[1,0]

    // Compute the determinant (no solution if det = 0).
    let det = self[0,0] * result[0,0] + self[0,1] * result[0,1] + self[0,2] * result[0,2]
    let invDet = 1.0 / det

    for col in 0 ..< 4 {
      for row in 0 ..< 4 {
        result[row,col] = result[row,col] * invDet
      }
    }

    return result
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
  public static func * (m: Matrix3, n: Matrix3) -> Matrix3 {
    var result = Matrix3.zero

    result[0,0] = m[0,0] * n[0,0] + m[0,1] * n[1,0] + m[0,2] * n[2,0]
    result[0,1] = m[0,0] * n[0,1] + m[0,1] * n[1,1] + m[0,2] * n[2,1]
    result[0,2] = m[0,0] * n[0,2] + m[0,1] * n[1,2] + m[0,2] * n[2,2]

    result[1,0] = m[1,0] * n[0,0] + m[1,1] * n[1,0] + m[1,2] * n[2,0]
    result[1,1] = m[1,0] * n[0,1] + m[1,1] * n[1,1] + m[1,2] * n[2,1]
    result[1,2] = m[1,0] * n[0,2] + m[1,1] * n[1,2] + m[1,2] * n[2,2]

    result[2,0] = m[2,0] * n[0,0] + m[2,1] * n[1,0] + m[2,2] * n[2,0]
    result[2,1] = m[2,0] * n[0,1] + m[2,1] * n[1,1] + m[2,2] * n[2,1]
    result[2,2] = m[2,0] * n[0,2] + m[2,1] * n[1,2] + m[2,2] * n[2,2]

    return result
  }

  /// Returns the transformation of a vector by a matrix.
  ///
  /// - Parameters:
  ///   - m: A transformation matrix.
  ///   - v: The vector to transform.
  public static func * (m: Matrix3, v: Vector3) -> Vector3 {
    return Vector3(
      x: (m[0,0] * v.x + m[0,1] * v.y + m[0,2] * v.z + m[0,3]),
      y: (m[1,0] * v.x + m[1,1] * v.y + m[1,2] * v.z + m[1,3]),
      z: (m[2,0] * v.x + m[2,1] * v.y + m[2,2] * v.z + m[2,3]))
  }

  /// The matrix whose all components are zero.
  public static var zero: Matrix3 {
    return Matrix3(columnMajor: Array(repeating: 0.0, count: 9))
  }

  /// The 3D rotation matrix representing the identity.
  public static var identity: Matrix3 {
    return Matrix3(columnMajor: [
      1.0, 0.0, 0.0,
      0.0, 1.0, 0.0,
      0.0, 0.0, 1.0,
    ])
  }

}
