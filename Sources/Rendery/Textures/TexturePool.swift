/// A structure that manages a pool of textures.
struct TexturePool {

  /// Initializes a texture pool for the specified set of parameters.
  ///
  /// - Parameters:
  ///   - size: The size of the texture managed by this pool. This must be a power of two.
  ///   - format: The internal format of the textures managed by this pool.
  ///   - wrapMethod: The wrapping behavior of the textures managed by this pool.
  init(size: Int, format: Texture.InternalFormat, wrapMethod: Texture.WrapMethod) {
    self.size = size
    self.format = format
    self.wrapMethod = wrapMethod
  }

  /// The size of the textures managed by this pool.
  let size: Int

  /// The internal format of the textures managed by this pool.
  let format: Texture.InternalFormat

  /// The wrapping behavior of the textures managed by this pool.
  let wrapMethod: Texture.WrapMethod

  /// The textures managed by this pool.
  private var textures: [MutableTexture] = []

  /// Returns a texture from the pool, allocating it if necessary.
  mutating func get() -> MutableTexture {
    for i in 0 ..< textures.count where isKnownUniquelyReferenced(&textures[i]) {
      return textures[i]
    }

    let texture = MutableTexture(width: size, height: size, format: format, wrapMethod: wrapMethod)
    textures.append(texture)
    return texture
  }

  /// Releases unused textures.
  mutating func releaseUnused() {
    var i = 0
    while i < textures.count {
      if isKnownUniquelyReferenced(&textures[i]) {
        textures.remove(at: i)
      } else {
        i += 1
      }
    }
  }

}
