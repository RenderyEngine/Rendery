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

  /// The meshes that describe the model's geometry.
  public var meshes: [Mesh]

  /// The model's bounding box.
  public var boundingBox: Box {
    guard !meshes.isEmpty
      else { return Box(origin: .zero, dimensions: .zero) }

    var minPoint = meshes[0].boundingBox.origin
    var maxPoint = meshes[0].boundingBox.origin + meshes[0].boundingBox.dimensions
    for mesh in meshes.dropFirst() {
      if mesh.boundingBox.origin.x < minPoint.x {
        minPoint.x = mesh.boundingBox.origin.x
      } else if mesh.boundingBox.origin.x > maxPoint.x {
        maxPoint.x = mesh.boundingBox.origin.x
      }

      if mesh.boundingBox.origin.y < minPoint.y {
        minPoint.y = mesh.boundingBox.origin.y
      } else if mesh.boundingBox.origin.x > maxPoint.y {
        maxPoint.y = mesh.boundingBox.origin.y
      }

      if mesh.boundingBox.origin.z < minPoint.z {
        minPoint.z = mesh.boundingBox.origin.z
      } else if mesh.boundingBox.origin.z > maxPoint.z {
        maxPoint.z = mesh.boundingBox.origin.z
      }
    }

    return Box(origin: minPoint, dimensions: maxPoint - minPoint)
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
  /// - Note: `pivotPoint.z` should always be `0.0` for models that are used as sprites, as only
  ///   node positions are considered to compute z-ordering while rendering 2D scenes.
  public var pivotPoint: Vector3 = Vector3(x: 0.5, y: 0.5, z: 0.5)

  /// Draws the model's meshes with the specified transform, skinned by their respective material.
  ///
  /// - Parameters:
  ///   - vpMatrix: The view-projection matrix.
  ///   - ambient: The scene's ambient light.
  ///   - lightNodes: The nodes with an attached light source which may interact with the model.
  ///   - node: The node being rendered.
  internal func draw(vpMatrix: Matrix4, ambient: Color, lightNodes: [Node3D], node: Node3D) {
    for (index, mesh) in meshes.enumerated() {
      // Makes sure the mesh is loaded.
      mesh.load()

      // Determine the mesh's material.
      var material: Material
      if materials.isEmpty {
        material = Material(program: .default)
      } else {
        material = meshes.count <= materials.count
          ? materials[index]
          : materials[index % materials.count]
      }

      // Makes sure the material's shader program is loaded.
      do {
        try material.shader.load()
      } catch {
        // Fallback on the default material.
        LogManager.main.log(error, level: .error)
        material = Material(program: .default)
      }

      // Compute the model transform.
      var modelMatrix = node.sceneTransform
      if pivotPoint != Vector3(x: 0.5, y: 0.5, z: 0.5) {
        let bb = boundingBox
        let translation = (Vector3.unitScale - pivotPoint) * bb.dimensions + bb.origin
        modelMatrix = modelMatrix * Matrix4(translation: translation)
      }

      // Install the shader program.
      material.shader.install()
      let context = DrawingContext(
        material: material,
        ambient: ambient,
        lightNodes: lightNodes,
        modelMatrix: modelMatrix,
        mvpMatrix: vpMatrix * modelMatrix)
      withUnsafePointer(to: context, { ptr in material.shader.bind(UnsafeRawPointer(ptr)) })

      // Draw the mesh.
      mesh.draw()
    }
  }

  /// The drawing context of a shader program used to draw a model.
  public struct DrawingContext {

    /// The mesh's material.
    let material: Material

    /// The scene's ambient light.
    let ambient: Color

    /// The nodes with an attached light source that may impact the mesh's appearence.
    let lightNodes: [Node3D]

    /// The model matrix that transforms local coordinates into the scene's coordinates.
    let modelMatrix: Matrix4

    /// The model-view-projection matrix that transforms local coordinates into the clip space.
    let mvpMatrix: Matrix4

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
    material.diffuse = .texture(Texture(source: image, wrappingMethod: .clamped))

    // Creates the model's material
    return Model(meshes: [mesh],  materials: [material])
  }

}
