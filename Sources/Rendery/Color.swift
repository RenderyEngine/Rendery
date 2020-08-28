import Numerics

/// A structure that stores a RGBA color value.
public struct Color: Hashable {

  /// Initializes a color with the specified components given.
  ///
  /// All components are expected to be given in the range `0.0 ... 1.0`.
  ///
  /// - Parameters:
  ///   - red: The color's red component.
  ///   - green: The color's green component.
  ///   - blue: The color's blue component.
  ///   - opacity: The color's alpha component.
  public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
    self.red   = red
    self.green = green
    self.blue  = blue
    self.alpha = alpha
  }

  /// Initializes a color from its HSLA representation.
  ///
  /// All components are expected to be given in the range `0.0 ... 1.0`.
  ///
  /// - Parameters:
  ///   - hue: The color's hue component.
  ///   - saturation: The color's saturation component.
  ///   - lightness: The color's lightness component.
  ///   - opacity: The color's alpha component.
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

    self.red   = rgbp[0] + m
    self.green = rgbp[1] + m
    self.blue  = rgbp[2] + m
    self.alpha = alpha
  }

  /// The color's red component.
  public var red: Double

  /// The color's green component.
  public var green: Double

  /// The color's blue component.
  public var blue: Double

  /// The color's alpha component.
  public var alpha: Double

  /// Converts the color into sRGB space, assuming it is encoded in linear RGB space.
  ///
  /// - Parameter gamma: The monitor's gamma value.
  public func srgb(gamma: Double = 2.2) -> Color {
    let i = 1.0 / gamma
    func lin2srgb(_ lin: Double) -> Double {
      return lin > 0.0031308
        ? 1.055 * Double.pow(lin, i) - 0.055
        : 12.92 * lin
    }

    return Color(red: lin2srgb(red), green: lin2srgb(green), blue: lin2srgb(blue), alpha: alpha)
  }

  /// Converts the color into linear RGB space, assuming it is encoded in sRGB space.
  public func linear(gamma: Double = 2.2) -> Color {
    func srgb2lin(_ s: Double) -> Double {
      return s <= 0.0404482362771082
        ? s / 12.92
        : Double.pow(((s + 0.055) / 1.055), gamma)
    }

    return Color(red: srgb2lin(red), green: srgb2lin(green), blue: srgb2lin(blue), alpha: alpha)
  }

  /// The HSLA representation of the color.
  public var hsla: (hue: Double, saturation: Double, lightness: Double, alpha: Double) {
    let maxComp = max(red, green, blue)
    let minComp = min(red, green, blue)
    let l = (maxComp + minComp) / 2.0

    if maxComp == minComp {
      // All components are identical, therefore the color is just a shade of gray.
      return (hue: 0.0, saturation: 0.0, lightness: l, alpha: alpha)
    } else {
      let delta = maxComp - minComp
      let s = l > 0.5
        ? delta / (2.0 - maxComp - minComp)
        : delta / (maxComp + minComp)

      let h: Double
      switch maxComp {
      case red  : h = (green - blue) / delta + (green < blue ? 6.0 : 0.0)
      case green: h = (blue - red) / delta + 2.0
      default   : h = (red - green) / delta + 4.0
      }

      return (hue: h / 6.0, saturation: s, lightness: l, alpha: alpha)
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
  ///   - alpha: The alpha value to set, in the range `0.0 ... 1.0`.
  ///   - premultiplied: A flag that indicates whether `alpha` should be premultiplied with the
  ///     color channels.
  public func with(alpha: Double, premultiplied: Bool = false) -> Color {
    return premultiplied
      ? Color(red: red * alpha, green: green * alpha, blue : blue * alpha, alpha: alpha)
      : Color(red: red, green: green, blue: blue, alpha: alpha)
  }

  /// The white color.
  public static var white = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

  /// The black color.
  public static var black = Color(red: 0, green: 0, blue: 0, alpha: 1.0)

  /// The default red color.
  public static var red = Color(red: 0.91, green: 0.16, blue: 0.22, alpha: 1.0)

  /// The default purple color.
  public static var purple = Color(red: 0.31, green: 0.21, blue: 0.35, alpha: 1.0)

  /// The default blue color.
  public static var blue = Color(red: 0.12, green: 0.56, blue: 1.0, alpha: 1.0)

  /// The default green color.
  public static var green = Color(red: 0.12, green: 1.0, blue: 0.55, alpha: 1.0)

  /// The default yellow color.
  public static var yellow = Color(red: 1.0, green: 0.93, blue: 0.53, alpha: 1.0)

  /// The transparent color.
  public static var transparent = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

  /// A random color.
  public static var random: Color {
    return Color(
      red  : Double.random(in: 0 ... 1.0),
      green: Double.random(in: 0 ... 1.0),
      blue : Double.random(in: 0 ... 1.0))
  }

}

extension Color: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    precondition(value.starts(with: "#"), "Hex triplets must start with '#'.")
    precondition(value.count == 7, "Hex triplets must have 6 hexadecimal digits.")

    self.red   = Double(UInt8(value.dropFirst(1).prefix(2), radix: 16)!) / 255.0
    self.green = Double(UInt8(value.dropFirst(3).prefix(2), radix: 16)!) / 255.0
    self.blue  = Double(UInt8(value.dropFirst(5).prefix(2), radix: 16)!) / 255.0
    self.alpha = 1.0
  }

}
