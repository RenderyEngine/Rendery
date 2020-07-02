import CGLFW

extension GL {

  internal class APIInterceptor {

    /// The program currently installed.
    internal private(set) var program: GL.UInt = 0

    internal func useProgram(_ program: GL.UInt) {
      guard self.program != program
        else { return }

      glUseProgram(program)
      self.program = program

      intUniforms  = [:]
      vec2Uniforms = [:]
      vec3Uniforms = [:]
      vec4Uniforms = [:]
      mat3Uniforms = [:]
      mat4Uniforms = [:]
    }

    internal func clearProgramCache(program: GL.UInt) {
      uniformLocations[program] = [:]
    }

    /// Uniform locations.
    internal private(set) var uniformLocations: [GL.UInt: [String: GL.Int]] = [:]

    internal func getUniformLocation(program: GL.UInt, name: String) -> GL.Int {
      var locations = uniformLocations[program, default: [:]]
      if let location = locations[name] {
        return location
      }

      let location = glGetUniformLocation(program, name)
      locations[name] = glGetUniformLocation(program, name)
      uniformLocations[program] = locations
      return location
    }

    /// The values assigned to boolean `int` uniform variables through `glUniform1i`.
    internal private(set) var intUniforms: [GL.Int: GL.Int] = [:]

    internal func uniform(location: GL.Int, value: GL.Int) {
      guard intUniforms[location] != value
        else { return }

      glUniform1i(location, value)
      intUniforms[location] = value
    }

    /// The values assigned to `vec2` uniform variables through `glUniform3f`.
    internal private(set) var vec2Uniforms: [GL.Int: GLSL.Vec2] = [:]

    internal func uniform(location: GL.Int, value: GLSL.Vec2) {
      guard vec2Uniforms[location] != value
        else { return }

      glUniform2f(location, value.x, value.y)
      vec2Uniforms[location] = value
    }

    /// The values assigned to `vec3` uniform variables through `glUniform3f`.
    internal private(set) var vec3Uniforms: [GL.Int: GLSL.Vec3] = [:]

    internal func uniform(location: GL.Int, value: GLSL.Vec3) {
      guard vec3Uniforms[location] != value
        else { return }

      glUniform3f(location, value.x, value.y, value.z)
      vec3Uniforms[location] = value
    }

    /// The values assigned to `vec4` uniform variables through `glUniform4f`.
    internal private(set) var vec4Uniforms: [GL.Int: GLSL.Vec4] = [:]

    internal func uniform(location: GL.Int, value: GLSL.Vec4) {
      guard vec4Uniforms[location] != value
        else { return }

      glUniform4f(location, value.x, value.y, value.z, value.w)
      vec4Uniforms[location] = value
    }

    /// The values assigned to `mat3` uniform variables through `glUniformMatrix3fv`.
    internal private(set) var mat3Uniforms: [GL.Int: GLSL.Mat3] = [:]

    internal func uniform(location: GL.Int, value: GLSL.Mat3) {
      guard mat3Uniforms[location] != value
        else { return }

      withUnsafePointer(to: value, { (pointer: UnsafePointer<GLSL.Mat3>) in
        let components = UnsafeRawPointer(pointer).assumingMemoryBound(to: Float.self)
        glUniformMatrix3fv(location, 1, 0, components)
      })
      mat3Uniforms[location] = value
    }

    /// The values assigned to `mat4` uniform variables through `glUniformMatrix4fv`.
    internal private(set) var mat4Uniforms: [GL.Int: GLSL.Mat4] = [:]

    internal func uniform(location: GL.Int, value: GLSL.Mat4) {
      guard mat4Uniforms[location] != value
        else { return }

      withUnsafePointer(to: value, { (pointer: UnsafePointer<GLSL.Mat4>) in
        let components = UnsafeRawPointer(pointer).assumingMemoryBound(to: Float.self)
        glUniformMatrix4fv(location, 1, 0, components)
      })
      mat4Uniforms[location] = value
    }

  }

}
