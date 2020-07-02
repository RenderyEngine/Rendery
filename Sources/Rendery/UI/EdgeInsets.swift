/// A set of offset values in each of the four cardinal directions.
public struct EdgeInsets: Hashable {

  public init(
    top   : Double = 0.0,
    left  : Double = 0.0,
    bottom: Double = 0.0,
    right : Double = 0.0
  ) {
    self.top    = top
    self.left   = left
    self.bottom = bottom
    self.right  = right
  }

  public var top   : Double

  public var left  : Double

  public var bottom: Double

  public var right : Double

}
