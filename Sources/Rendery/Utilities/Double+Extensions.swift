extension Double {

  internal static var defaultTolerance: Double { 0.001 }

  internal func isEqual(to other: Double, withTolerance tolerance: Double) -> Bool {
    return abs(self - other) <= tolerance
  }

}
