/// A 3D drawable object.
///
/// A model abstracts over the different elements that describe how to render a particular 3D
/// object. It is essentially a composition of one or several meshes, which describe its geometry
/// (or shape) and one or several materials, which describe its appearance (or skin).
///
/// A model only provides the visual description of a 3D object (i.e. geometry and appearance). Its
/// translation and orientation in a scene is determined by attaching it to a scene node. Multiple
/// nodes may use the same model instance, allowing it to appear at different positions.
///
/// You may share meshes across multiple models with different materials, allowing the same shape
/// to to appear with different skins while saving graphics memory. Models (and their materials)
/// are value-types, therefore material variations will not be shared across multiple instances.
public struct Model {

  /// Initializes a model from an array of meshes and an array materials.
  ///
  /// - Parameters:
  ///   - meshes: The model's meshes.
  ///   - materials: The model's materials. If this is left empty, the model will be drawn with a
  ///     default white material.
  public init(meshes: [Mesh], materials: [Material] = []) {
    self.meshes = meshes
    self.materials = materials
  }

  /// The model's name.
  ///
  /// This property can be used to provide a descriptive name for the model, to make managing the
  /// contents of your scenes easier.
  public var name: String?

  /// The meshes that describe the model's geometry.
  public var meshes: [Mesh]

  /// The model's axis-aligned bounding box.
  public var aabb: AxisAlignedBox {
    guard !meshes.isEmpty
      else { return AxisAlignedBox(origin: .zero, dimensions: .zero) }

    var minPoint = meshes[0].aabb.origin
    var maxPoint = meshes[0].aabb.origin + meshes[0].aabb.dimensions
    for mesh in meshes.dropFirst() {
      if mesh.aabb.origin.x < minPoint.x {
        minPoint.x = mesh.aabb.origin.x
      } else if mesh.aabb.origin.x > maxPoint.x {
        maxPoint.x = mesh.aabb.origin.x
      }

      if mesh.aabb.origin.y < minPoint.y {
        minPoint.y = mesh.aabb.origin.y
      } else if mesh.aabb.origin.x > maxPoint.y {
        maxPoint.y = mesh.aabb.origin.y
      }

      if mesh.aabb.origin.z < minPoint.z {
        minPoint.z = mesh.aabb.origin.z
      } else if mesh.aabb.origin.z > maxPoint.z {
        maxPoint.z = mesh.aabb.origin.z
      }
    }

    return AxisAlignedBox(origin: minPoint, dimensions: maxPoint - minPoint)
  }

  /// The materials that describe the model's skin.
  ///
  /// If a model has the same number of materials as it has meshes, the material index corresponds
  /// to the mesh index. Otherwise, the material index for each mesh is given by the index of that
  /// mesh module the number of materials. If it has no material at all, it will be drawn with a
  /// default white material.
  public var materials: [Material]

  /// The point in the model that corresponds to the node's position when attached.
  ///
  /// The value of this property is given in normalized coordinates and specifies a translation of
  /// the pivot point. The default value is `(x: 0.5, y: 0.5, z: 0.5)`, which centers model on its
  /// origin. A value of `0.0` or `1.0` on a given axis indicates that the pivot point reaches the
  /// edge of the model's bounding box
  ///
  /// - Note: `pivotPoint.z` should always be `0.5` for models that are used as sprites, as only
  ///   node positions are considered to compute z-ordering while rendering 2D scenes.
  public var pivotPoint: Vector3 = Vector3(x: 0.5, y: 0.5, z: 0.5)

  /// A flag that indicates whether the model should be drawn with an outline.
  public var isOutlined: Bool = false

  /// The color of the border when the model is outlined.
  public var outlineColor: Color = .blue

  /// The drawing context of provided to a shader program to render the color pass of a model.
  public struct ColorPassContext {

    /// The mesh's material.
    var material: Material

    /// The scene's ambient light.
    var ambient: Color

    /// The nodes with an attached light source that may impact the mesh's appearence.
    var lightNodes: [Node]

    /// The model matrix that transforms local coordinates into the scene's coordinates.
    var modelMatrix: Matrix4

    /// The model-view-projection matrix that transforms local coordinates into the clip space.
    var modelViewProjectionMatrix: Matrix4

  }

  /// Initializes a model composed of a flat quad and a texture built from the specified image.
  ///
  /// In Rendery, the term "sprite" is used to denote a model composed of a single quad (i.e., a
  /// box mesh without any depth) that's skinned by a texture. It is typically used to approximate
  /// 3D objects by keeping it perpendicular to the camera, to conceal the absence of depth.
  public static func sprite(fromImage image: Image) -> Model {
    // Creates the model's mesh.
    let rectangle = Rectangle(
      centeredAt: .zero,
      dimensions: Vector2(x: Double(image.width), y: Double(image.height)))
    let mesh = Mesh.rectangle(rectangle)

    // Creates the model's material. The texture is clamped to avoid any artifacts at the texture's
    // edges, caused by interpolated border values.
    var material = Material(program: .default)
    material.diffuse = .texture(Texture(
      source: image,
      wrappingMethod: (u: .clampedToBorder, v: .clampedToBorder)))

    // Creates the model's material
    return Model(meshes: [mesh],  materials: [material])
  }

}
