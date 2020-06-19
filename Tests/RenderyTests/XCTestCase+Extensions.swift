import XCTest
import Rendery

let accuracyOfEquality = 0.00001

extension XCTestCase {

  func assertEqual(_ lhs: Matrix4, _ rhs: Matrix4, accuracy: Double) {
    for i in 0 ..< 16 {
      XCTAssertEqual(lhs.components[i], rhs.components[i], accuracy: accuracy)
    }
  }

  func assertEqual(_ lhs: Vector3, _ rhs: Vector3, accuracy: Double) {
    XCTAssertEqual(lhs.x, rhs.x, accuracy: accuracy)
    XCTAssertEqual(lhs.y, rhs.y, accuracy: accuracy)
    XCTAssertEqual(lhs.z, rhs.z, accuracy: accuracy)
  }

}
