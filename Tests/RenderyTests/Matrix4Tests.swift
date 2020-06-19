import XCTest
import Rendery

final class Matrix4Tests: XCTestCase {

  func testInitWithTranslation() {
    let mat = Matrix4(translation: Vector3(x: 12.0, y: -6.0, z: 3.0))

    XCTAssertEqual(mat[0,3], 12.0)
    XCTAssertEqual(mat[1,3], -6.0)
    XCTAssertEqual(mat[2,3], 3.0)
  }

  func testInitWithRotation() {
    let mat = Matrix4(rotation: Quaternion.init(axis: .unitY, angle: .rad(0.3)))

    XCTAssertEqual(mat[0,0],  0.9553365, accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[0,1],  0.0      , accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[0,2],  0.2955202, accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[1,0],  0.0      , accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[1,1],  1.0      , accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[1,2],  0.0      , accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[2,0], -0.2955202, accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[2,1],  0.0      , accuracy: accuracyOfEquality)
    XCTAssertEqual(mat[2,2],  0.9553365, accuracy: accuracyOfEquality)
  }

  func testInitWithScale() {
    let mat = Matrix4(scale: Vector3(x: 12.0, y: -6.0, z: 3.0))

    XCTAssertEqual(mat[0,0], 12.0)
    XCTAssertEqual(mat[1,1], -6.0)
    XCTAssertEqual(mat[2,2], 3.0)
  }

  func testSubscript() {
    var mat = Matrix4.zero
    for row in 0 ..< 4 {
      for col in 0 ..< 4 {
        mat[row,col] = Double(row + 4 * col)
        XCTAssertEqual(mat[row,col], Double(row + 4 * col))
      }
    }

    // Make sure the matrix's memory layout is column-major.
    let components = Array(stride(from: 0.0, to: 16.0, by: 1.0))
    XCTAssertEqual(mat.components, components)
  }

  func testTransposed() {
    var mat = Matrix4.zero
    for row in 0 ..< 4 {
      for col in 0 ..< 4 {
        mat[row,col] = Double.random(in: 0.0 ..< 1.0)
      }
    }

    let res = mat.transposed
    for row in 0 ..< 4 {
      for col in 0 ..< 4 {
        XCTAssertEqual(mat[row,col], res[col,row])
      }
    }
  }

  func testDeterminant() {
    XCTAssertEqual(Matrix4.identity.determinant, 1.0, accuracy: accuracyOfEquality)

    let matrix = Matrix4(
      translation: Vector3(x: 12.0, y: -6.0, z: 3.0),
      rotation: Quaternion(axis: Vector3.unitScale.normalized, angle: .rad(0.3)),
      scale: .unitScale * 2)
    XCTAssertEqual(matrix.determinant, 8.0, accuracy: accuracyOfEquality)
  }

  func testInverted() {
    XCTAssertEqual(Matrix4.identity.inverted, Matrix4.identity)

    let mat = Matrix4(
      translation: Vector3(x: 12.0, y: -6.0, z: 3.0),
      rotation: Quaternion(axis: Vector3.unitScale.normalized, angle: .rad(0.3)),
      scale: .unitScale * 2)
    let res = mat.inverted.transposed

    // Numbers computed with https://planetcalc.com
    XCTAssertEqual(res.components[0] ,  0.4851121630418686, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[1] ,  0.0927532539125148, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[2] , -0.0778654169543834, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[3] , -5.0312301821641846, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[4] , -0.0778654169543834, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[5] ,  0.4851121630418686, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[6] ,  0.0927532539125148, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[7] ,  3.5667982199662690, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[8] ,  0.0927532539125148, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[9] , -0.0778654169543834, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[10],  0.4851121630418686, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[11], -3.0355680378020841, accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[12],  0.0               , accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[13],  0.0               , accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[14],  0.0               , accuracy: accuracyOfEquality)
    XCTAssertEqual(res.components[15],  1.0               , accuracy: accuracyOfEquality)

    let matrices = [
      Matrix4.init(rotation: Quaternion(axis: .unitX, angle: .rad(0.3))),
      Matrix4.init(rotation: Quaternion(axis: .unitY, angle: .rad(0.3))),
      Matrix4.init(rotation: Quaternion(axis: .unitZ, angle: .rad(0.3))),
      Matrix4.init(scale: Vector3(x: 1.0 / 8.0, y: 1.0 / 2.0, z: 1.0 / 4.0)),
      Matrix4.init(translation: Vector3(x: 1.0, y: 2.0, z: 3.0)),
    ]

    for matrix in matrices {
      let inverse = matrix.inverted

      // If B = A^-1, then A * B = Identity.
      XCTAssertEqual(matrix * inverse, Matrix4.identity)

      // The determinant of the inverse should be the reciprocal.
      XCTAssertEqual(matrix.determinant * inverse.determinant, 1.0, accuracy: accuracyOfEquality)
    }
  }

  func testMultiplyByMatrix4() {
    var lhs = Matrix4.zero
    lhs[0,0] = 2.0  ; lhs[1,0] = 3.0  ; lhs[2,0] = 5.0  ; lhs[3,0] = 7.0
    lhs[0,1] = 11.0 ; lhs[1,1] = 13.0 ; lhs[2,1] = 17.0 ; lhs[3,1] = 19.0
    lhs[0,2] = 23.0 ; lhs[1,2] = 29.0 ; lhs[2,2] = 31.0 ; lhs[3,2] = 37.0
    lhs[0,3] = 41.0 ; lhs[1,3] = 43.0 ; lhs[2,3] = 47.0 ; lhs[3,3] = 53.0

    var rhs = Matrix4.zero
    rhs[0,0] = 59.0 ; rhs[1,0] = 61.0 ; rhs[2,0] = 67.0 ; rhs[3,0] = 71.0
    rhs[0,1] = 73.0 ; rhs[1,1] = 79.0 ; rhs[2,1] = 83.0 ; rhs[3,1] = 89.0
    rhs[0,2] = 97.0 ; rhs[1,2] = 101.0; rhs[2,2] = 103.0; rhs[3,2] = 107.0
    rhs[0,3] = 109.0; rhs[1,3] = 113.0; rhs[2,3] = 127.0; rhs[3,3] = 131.0

    let res = lhs * rhs
    XCTAssertEqual(res.components[0] , 5241.0)
    XCTAssertEqual(res.components[1] , 5966.0)
    XCTAssertEqual(res.components[2] , 6746.0)
    XCTAssertEqual(res.components[3] , 7814.0)
    XCTAssertEqual(res.components[4] , 6573.0)
    XCTAssertEqual(res.components[5] , 7480.0)
    XCTAssertEqual(res.components[6] , 8464.0)
    XCTAssertEqual(res.components[7] , 9800.0)
    XCTAssertEqual(res.components[8] , 8061.0)
    XCTAssertEqual(res.components[9] , 9192.0)
    XCTAssertEqual(res.components[10], 10424.0)
    XCTAssertEqual(res.components[11], 12080.0)
    XCTAssertEqual(res.components[12], 9753.0)
    XCTAssertEqual(res.components[13], 11112.0)
    XCTAssertEqual(res.components[14], 12560.0)
    XCTAssertEqual(res.components[15], 14552.0)
  }

  func testMultiplyByVector3() {
    XCTAssertEqual(Matrix4.identity * Vector3.unitScale, Vector3.unitScale)

    let mat0 = Matrix4(translation: Vector3(x: 1.0, y: 0.0, z:-1.0))
    XCTAssertEqual(mat0 * Vector3.unitScale, Vector3(x: 2.0, y: 1.0, z: 0.0))

    let mat1 = Matrix4(rotation: Quaternion(axis: .unitY, angle: .deg(90.0)))
    assertEqual(
      mat1 * Vector3.unitScale,
      Vector3(x: 1.0, y: 1.0, z: -1.0),
      accuracy: accuracyOfEquality)

    let mat2 = Matrix4(scale: Vector3(x: 1.0, y: 0.0, z:-1.0))
    XCTAssertEqual(mat2 * Vector3.unitScale, Vector3(x: 1.0, y: 0.0, z: -1.0))
  }

  func testLookAt() {
    let mat = Matrix4.lookAt(
      from: Vector3.zero,
      to: Vector3(x: 0.0, y: 1.0, z: -1.0),
      up: Vector3.unitY)

    let rot = Matrix4(rotation: Quaternion(axis: Vector3.unitX, angle: .deg(45.0)))
    assertEqual(mat, rot, accuracy: accuracyOfEquality)
  }

}
