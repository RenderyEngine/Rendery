import Cgltf
import Foundation

public final class GLTFFile: InitializableFromFile {

  public init?(contentsOfFile filename: String) {
    var options = cgltf_options()
    guard GLTFFile.checkSuccess(of: cgltf_parse_file(&options, filename, &data))
      else { return nil }
    guard GLTFFile.checkSuccess(of: cgltf_load_buffers(&options, data, filename))
      else { return nil }
    guard GLTFFile.checkSuccess(of: cgltf_validate(data))
      else { return nil }
  }

  public var models: [Model] {
    var results: [Model] = []

    // Rendery's concept of model actually corresponds to that of mesh in glTF. Each node can have
    // at most one mesh (optionally skinned by a so-called `skin` object), and each mesh can have
    // several primitives (which incidentally correspond to Rendery's meshes).
    for i in 0 ..< data!.pointee.meshes_count {
      results.append(GLTFFile.buildModel(from: data!.pointee.meshes.advanced(by: i).pointee))
    }

    return results
  }

  private static func buildModel(from gltfMesh: cgltf_mesh) -> Model {
    var materialCache: [UnsafeMutablePointer<cgltf_material>?: Material] = [:]

    var model = Model(meshes: [], materials: [])
    model.name = String(cString: gltfMesh.name, encoding: .utf8)

    // Extract the primitives (i.e., the "meshes" in Rendery's parlance).
    for i in 0 ..< gltfMesh.primitives_count {
      let primitive = gltfMesh.primitives.advanced(by: i).pointee

      // Extract the mesh.
      guard let mesh = extractMesh(from: primitive)
        else { continue }
      model.meshes.append(mesh)

      // Extract the mesh's material, if any.
      let material: Material
      if let m = materialCache[primitive.material] {
        material = m
      } else if let gltfMaterial = primitive.material?.pointee {
        material = extractMaterial(from: gltfMaterial)
        materialCache[primitive.material] = material
      } else {
        material = Material(program: .default)
      }
      model.materials.append(material)
    }

    return model
  }

  private static func extractMaterial(from gltfMaterial: cgltf_material) -> Material {
    var material = Material(program: .default)

    if gltfMaterial.has_pbr_metallic_roughness != 0 {
      let pbr = gltfMaterial.pbr_metallic_roughness

      // Extract the material's base color (given in the sRGB color space). According to the
      // specification, this should be used as a linear multiplier for each texture value.
      let baseColorFactors = pbr.base_color_factor
      material.multiply = .color(Color(
        red  : UInt8(baseColorFactors.0 * 255.0),
        green: UInt8(baseColorFactors.1 * 255.0),
        blue : UInt8(baseColorFactors.2 * 255.0),
        alpha: UInt8(baseColorFactors.3 * 255.0)))

      // Extract the material's diffuse texture, if any.
      if let gltfTexture = pbr.base_color_texture.texture?.pointee,
         let texture = extractTexture(from: gltfTexture)
      {
        material.diffuse = .texture(texture)
      }

      // TODO: Handle the other properties of the PBR model.
    }

    if gltfMaterial.has_pbr_specular_glossiness != 0 {
      // https://tinyurl.com/y8rcol22
      LogManager.main.log("Unsupported specular-glossiness material extension.", level: .debug)
    }
    if gltfMaterial.has_clearcoat != 0 {
      // https://tinyurl.com/y9zkynaf
      LogManager.main.log("Unsupported clear coat material extension.", level: .debug)
    }

    return material
  }

  private static func extractTexture(from gltfTexture: cgltf_texture) -> Texture? {
    var image: Image?

    // Load the image data.
    // if let uri = (gltfTexture.image.pointee.uri as Optional).map({ String(cString: $0) }) {
    if gltfTexture.image.pointee.uri != nil {
      // TODO: Load base64-embedded and external texture data.
      LogManager.main.log("Unsupported texture data.", level: .debug)
    } else if let bufferView = gltfTexture.image.pointee.buffer_view?.pointee {
      // The image data should be extracted from a blob.
      var base = bufferView.buffer.pointee.data.advanced(by: bufferView.offset)
      var data: Data
      if bufferView.stride <= 1 {
        data = Data(bytes: base, count: bufferView.size)
      } else {
        data = Data(capacity: bufferView.size)
        for _ in 0 ..< bufferView.size {
          data.append(base.load(as: UInt8.self))
          base = base.advanced(by: bufferView.stride)
        }
      }

      image = Image(data: data)
    }

    guard image != nil else {
      LogManager.main.log("Failed to extract texture data.", level: .error)
      return nil
    }

    // Extract the sampler's settings, if any.
    var uWrap = Texture.WrappingMethod.repeat
    var vWrap = Texture.WrappingMethod.repeat

    if let sampler = gltfTexture.sampler?.pointee {
      if let method = Texture.WrappingMethod(glValue: GL.Enum(sampler.wrap_s)) {
        uWrap = method
      } else {
        LogManager.main.log("Unsupported wrapping method '\(sampler.wrap_s)'.", level: .warning)
      }

      if let method = Texture.WrappingMethod(glValue: GL.Enum(sampler.wrap_t)) {
        vWrap = method
      } else {
        LogManager.main.log("Unsupported wrapping method '\(sampler.wrap_t)'.", level: .warning)
      }

      // TODO: Handle texture filtering parameters (e.g., `mag_filter` and `min_filter`).
    }

    return Texture(source: image!, wrappingMethod: (uWrap, vWrap))
  }

  private static func extractMesh(from gltfPrimitive: cgltf_primitive) -> Mesh? {
    guard gltfPrimitive.type == cgltf_primitive_type_triangles else {
      // TODO: Support other kind of primitives.
      LogManager.main.log(
        "Unsupported primitive type '\(gltfPrimitive.type.rawValue)'.",
        level: .debug)
        return nil
    }

    // Read the vertex attributes.
    var positions: [Float] = []
    var normals  : [Float] = []
    var texcoords: [Float] = []

    for j in 0 ..< gltfPrimitive.attributes_count {
      let attribute = gltfPrimitive.attributes.advanced(by: j).pointee
      let accessor = attribute.data.pointee

      switch attribute.type {
      case cgltf_attribute_type_position:
        assert(positions.count == 0)
        assert(accessor.component_type == cgltf_component_type_r_32f)
        append(contentsOf: attribute, to: &positions)

      case cgltf_attribute_type_normal:
        assert(normals.count == 0)
        assert(accessor.component_type == cgltf_component_type_r_32f)
        append(contentsOf: attribute, to: &normals)

      case cgltf_attribute_type_texcoord:
        guard texcoords.isEmpty else {
          // TODO: By specification, client implementations should support at least two sets of
          // texture coordinates.
          LogManager.main.log(
            "Unsupported primitive attribute '\(attribute.type.rawValue)'.",
            level: .debug)
          continue
        }

        assert(accessor.component_type == cgltf_component_type_r_32f || accessor.normalized != 0)
        append(contentsOf: attribute, to: &texcoords)

      case cgltf_attribute_type_color,
           cgltf_attribute_type_tangent,
           cgltf_attribute_type_joints,
           cgltf_attribute_type_weights:
        // TODO: Support these attributes.
        LogManager.main.log(
          "Unsupported primitive attribute '\(attribute.type.rawValue)'.",
          level: .debug)

      default:
        assert(attribute.type == cgltf_attribute_type_invalid)
        LogManager.main.log("Invalid primitive attribute.", level: .error)
      }
    }

    // Read the vertex indices, if any.
    var indices: [UInt32]?
    if let accessor = gltfPrimitive.indices?.pointee {
      assert(accessor.is_sparse == 0)

      switch accessor.component_type {
      case cgltf_component_type_r_8u:
        indices = unpack(denseAccessor: accessor).map({ (i: UInt8) in UInt32(i) })
      case cgltf_component_type_r_16u:
        indices = unpack(denseAccessor: accessor).map({ (i: UInt16) in UInt32(i) })
      case cgltf_component_type_r_32u:
        indices = unpack(denseAccessor: accessor)
      default:
        fatalError("unreachable")
      }
    }

    // Make sure the extracted data looks correct.
    let vertexCount = positions.count / 3
    guard normals.isEmpty || normals.count == positions.count else {
      LogManager.main.log("Invalid primitive data.", level: .error)
      return nil
    }
    guard texcoords.isEmpty || texcoords.count == vertexCount * 2 else {
      LogManager.main.log("Invalid primitive data.", level: .error)
      return nil
    }

    // Merge all vertex data in a single array.
    var data: [Float] = []
    for i in 0 ..< positions.count / 3 {
      data.append(contentsOf: positions[i * 3 ..< (i + 1) * 3])
      if !normals.isEmpty {
        data.append(contentsOf: normals[i * 3 ..< (i + 1) * 3])
      }
      if !texcoords.isEmpty {
        data.append(contentsOf: texcoords[i * 2 ..< (i + 1) * 2])
      }
    }

    // Define the vertex attribute descriptors.
    var stride = 3 * MemoryLayout<Float>.stride
    if !normals.isEmpty {
      stride += 3 * MemoryLayout<Float>.stride
    }
    if !texcoords.isEmpty {
      stride += 2 * MemoryLayout<Float>.stride
    }

    var descriptors: [VertexAttributeDescriptor] = [.position(offset: 0, stride: stride)]
    if !normals.isEmpty {
      descriptors.append(.normal(offset: 3 * MemoryLayout<Float>.stride, stride: stride))
    }
    if !texcoords.isEmpty {
      descriptors.append(.uv(offset: 6 * MemoryLayout<Float>.stride, stride: stride))
    }

    // Create the mesh data.
    let source =  data.withUnsafeBufferPointer({ buffer in
      MeshData(
        vertexData: Data(buffer: buffer),
        vertexCount: vertexCount,
        vertexIndices: indices,
        attributeDescriptors: descriptors,
        primitiveType: .triangles) // FIXME: This depends on the type of the glTF primitive!
    })

    return Mesh(source: source)
  }

  private static func append(contentsOf attribute: cgltf_attribute, to array: inout [Float]) {
    // Get the size of the buffer to allocate.
    let capacity = cgltf_accessor_unpack_floats(attribute.data, nil, 0)
    let elements = UnsafeMutableBufferPointer<Float>.allocate(capacity: capacity)
    defer { elements.deallocate() }

    // Read data from the accessor.
    cgltf_accessor_unpack_floats(attribute.data, elements.baseAddress!, capacity)
    array.append(contentsOf: elements)
  }

  private static func unpack<T>(denseAccessor accessor: cgltf_accessor) -> [T] {
    assert(accessor.is_sparse == 0)

    var base = accessor.buffer_view.pointee.buffer.pointee.data
      .advanced(by: accessor.buffer_view.pointee.offset)
      .advanced(by: accessor.offset)

    let componentCount = cgltf_num_components(accessor.type)
    var result: [T] = []
    for _ in 0 ..< accessor.count {
      let start = base.assumingMemoryBound(to: T.self)
      result.append(contentsOf: UnsafeBufferPointer(start: start, count: componentCount))
      base = base.advanced(by: accessor.stride)
    }

    return result
  }

  /// The glTF data pointer.
  private var data: UnsafeMutablePointer<cgltf_data>?

  private static func checkSuccess(of result: cgltf_result) -> Bool {
    let error: String
    switch result {
    case cgltf_result_success:
      return true
    case cgltf_result_data_too_short:
      error = "data too short"
    case cgltf_result_unknown_format:
      error = "unknown format"
    case cgltf_result_invalid_json:
      error = "invalid JSON"
    case cgltf_result_invalid_gltf:
      error = "invalid glTF"
    case cgltf_result_invalid_options:
      error = "invalid options"
    case cgltf_result_file_not_found:
      error = "file not found"
    case cgltf_result_io_error:
      error = "file I/O error"
    case cgltf_result_out_of_memory:
      error = "out of memory"
    case cgltf_result_legacy_gltf:
      error = "legacy glTF"
    default:
      error = "unknown error"
    }

    LogManager.main.log("Failed to open glTF file: \(error).", level: .error)
    return false
  }

  deinit {
    cgltf_free(data)
  }

}
