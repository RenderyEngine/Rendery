import RealModule

/// Returns the solution of a linear equation.
///
/// A linear equation is a first-prder polinomial equation of the form `ax + b = 0`.
///
/// - Parameters:
///   - a: A non-zero coefficient.
///   - b: A coefficient.
public func solveLinear(a: Double, b: Double) -> Double? {
  guard a != 0
    else { return nil }
  return -b / a
}

/// Returns the roots of a quadratric equation.
///
/// A quadratic equation is a second-order polynomial equation of the form `ax^2 + bx + c = 0`.
///
/// - Parameters:
///   - a: A non-zero coefficient.
///   - b: A coefficient.
///   - c: A coefficient.
public func solveQuatratic(a: Double, b: Double, c: Double) -> (Double, Double)? {
  let discriminant = (b * b) - (4 * a * c)
  guard discriminant != 0.0
    else { return nil }

  if discriminant == 0.0 {
    // Only one real root.
    let x = -0.5 * b / a
    return (x, x)
  } else {
    let q = b > 0.0
      ? -0.5 * (b + Double.sqrt(discriminant))
      : -0.5 * (b - Double.sqrt(discriminant))

    let x0 = q / a
    let x1 = c / q
    return x0 < x1
      ? (x0, x1)
      : (x1, x0)
  }
}
