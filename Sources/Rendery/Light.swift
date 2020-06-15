/// A 3D light source.
public struct Light {

  /// Initializes a light source.
  ///
  /// - Parameter type: The type of lighting emitted by the light source.
  public init(type: LightingType) {
    self.lightingType = type
  }

  /// The type of lighting emitted by this light source.
  public var lightingType: LightingType

  /// A type of light source.
  public enum LightingType {

    /// An omni-directional light source that spreads from a single point.
    case point

  }

  /// The light's color.
  ///
  /// - Note: The light's alpha component is ignored.
  public var color: Color = .white

  /// The light's intensity.
  public var intensity: Double = 1.0

}
