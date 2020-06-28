/// A structure that stores a 32-bit RGBA color value.
public struct Color: Hashable {

  /// Initializes a color in the Generic RGB color space.
  ///
  /// - Parameters:
  ///   - red: The color's red component, in the range `0 ... 255`.
  ///   - green: The color's green component, in the range `0 ... 255`.
  ///   - blue: The color's blue component, in the range `0 ... 255`.
  ///   - opacity: The color's alpha component, in the range `0 ... 255`.
  public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
  }

  /// Initializes a color from its HSLA representation.
  ///
  /// - Parameters:
  ///   - hue: The color's hue component, in the range `0.0 ... 1.0`.
  ///   - saturation: The color's saturation component, in the range `0.0 ... 1.0`.
  ///   - lightness: The color's lightness component, in the range `0.0 ... 1.0`.
  ///   - opacity: The color's alpha component, in the range `0.0 ... 1.0`.
  public init(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) {
    let h = hue * 360.0

    let c = (1.0 - abs(2.0 * lightness - 1)) * saturation
    let x = c * (1 - abs((h / 60.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
    let m = lightness - c / 2.0

    let rgbp: [Double]
    switch h {
    case 0 ..< 60   : rgbp = [c, x, 0]
    case 60 ..< 120 : rgbp = [x, c, 0]
    case 120 ..< 180: rgbp = [0, c, x]
    case 180 ..< 240: rgbp = [0, x, c]
    case 240 ..< 300: rgbp = [x, 0, c]
    default         : rgbp = [c, 0, x]
    }

    self.red = UInt8((rgbp[0] + m) * 255.0)
    self.green = UInt8((rgbp[1] + m) * 255.0)
    self.blue = UInt8((rgbp[2] + m) * 255.0)
    self.alpha = UInt8(alpha * 255.0)
  }

  /// The color's red component.
  public var red: UInt8

  /// The color's green component.
  public var green: UInt8

  /// The color's blue component.
  public var blue: UInt8

  /// The color's alpha component.
  public var alpha: UInt8

  /// The HSLA representation of the color.
  public var hsla: (hue: Double, saturation: Double, lightness: Double, alpha: Double) {
    let rn = Double(red) / 255.0
    let gn = Double(green) / 255.0
    let bn = Double(blue) / 255.0

    let maxComp = max(rn, gn, bn)
    let minComp = min(rn, gn, bn)
    let l = (maxComp + minComp) / 2.0

    if maxComp == minComp {
      // All components are identical, therefore the color is just a shade of gray.
      return (hue: 0.0, saturation: 0.0, lightness: l, alpha: Double(alpha) / 255.0)
    } else {
      let delta = maxComp - minComp
      let s = l > 0.5
        ? delta / (2.0 - maxComp - minComp)
        : delta / (maxComp + minComp)

      let h: Double
      switch maxComp {
      case rn: h = (gn - bn) / delta + (gn < bn ? 6.0 : 0.0)
      case gn: h = (bn - rn) / delta + 2.0
      default: h = (rn - gn) / delta + 4.0
      }

      return (hue: h / 6.0, saturation: s, lightness: l, alpha: Double(alpha) / 255.0)
    }
  }

  /// A shade (i.e., darker variant) of the color.
  public var shade: Color {
    let (h, s, l, a) = hsla
    return Color(hue: h, saturation: s, lightness: max(0, l - 0.1), alpha: a)
  }

  /// A tint (i.e., brighter variant) of the color.
  public var tint: Color {
    let (h, s, l, a) = hsla
    return Color(hue: h, saturation: s, lightness: min(1, l + 0.1), alpha: a)
  }

  /// Returns this color with the alpha channel set to the specified value.
  ///
  /// - Parameters:
  ///   - alpha: The alpha value to set, in the range `0 ... 255`.
  ///   - premultiplied: A flag that indicates whether `alpha` should be premultiplied with the
  ///     color channels.
  public func with(alpha: UInt8, premultiplied: Bool = false) -> Color {
    if !premultiplied {
      return Color(red: red, green: green, blue: blue, alpha: alpha)
    } else {
      let iAlpha = Double(alpha) / 255.0
      return Color(
        red  : UInt8(Double(red) * iAlpha),
        green: UInt8(Double(green) * iAlpha),
        blue : UInt8(Double(blue) * iAlpha),
        alpha: alpha)
    }
  }

  /// The white color.
  public static var white = Color(red: 255, green: 255, blue: 255, alpha: 255)

  /// The black color.
  public static var black = Color(red: 0, green: 0, blue: 0, alpha: 255)

  /// The default red color.
  public static var red = Color(red: 230, green: 41, blue: 55, alpha: 255)

  /// The default purple color.
  public static var purple = Color(red: 81, green: 53, blue: 90, alpha: 255)

  /// The default blue color.
  public static var blue = Color(red: 30, green: 144, blue: 255, alpha: 255)

  /// The default green color.
  public static var green = Color(red: 30, green: 255, blue: 141, alpha: 255)

  /// The default yellow color.
  public static var yellow = Color(red: 255, green: 238, blue: 136, alpha: 255)

  /// The transparent color.
  public static var transparent = Color(red: 0, green: 0, blue: 0, alpha: 0)

  /// A random color.
  public static var random: Color {
    return Color(
      red  : UInt8.random(in: 0 ... 255),
      green: UInt8.random(in: 0 ... 255),
      blue : UInt8.random(in: 0 ... 255))
  }

}

extension Color: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    precondition(value.starts(with: "#"), "Hex triplets must start with '#'.")
    precondition(value.count == 7, "Hex triplets must have 6 hexadecimal digits.")

    self.red   = UInt8(value.dropFirst(1).prefix(2), radix: 16)!
    self.green = UInt8(value.dropFirst(3).prefix(2), radix: 16)!
    self.blue  = UInt8(value.dropFirst(5).prefix(2), radix: 16)!
    self.alpha = 255
  }

}
