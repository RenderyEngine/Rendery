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
    ///
    /// The light is emitted from the position of the node to which it is attached. Rotation and
    /// scale do not affect a point light's behavior.
    case point

    /// A light source that spreads in a cone-shaped beam.
    ///
    /// The light is emitted from the position of the node to which it is attached, and spreads in
    /// the direction of the node's rotation. Scale does not affect a spot light's behavior.
    case spot

    /// An infinitely far directional light source that emits light in a single direction.
    ///
    /// Directional lights are typically used to simulate large and distant light emitters, such as
    /// the sun or the moon. The light's direction is defined by the rotation of the node to which
    /// it is attached. Translation and scale do not affect a directional light's behavior.
    case directional

  }

  /// The light's color.
  ///
  /// - Note: The light's alpha component is ignored.
  public var color: Color = .white

  /// The light's intensity.
  public var intensity = 1.0

  /// The light's range.
  ///
  /// For a point light, this property defines the radius of a sphere delimiting the area being
  /// lit. Similarly, it defines the length of a cone for a spot light.
  public var range: Double = 10.0

  /// The light's angle.
  ///
  /// This property is only relevant for a spot light, and defines the width of a cone delimiting
  /// the area being lit.
  public var angle: Angle = .deg(45.0)

  /// A flag that indicates whether this light casts shadows.
  public var isCastingShadow = false

}
