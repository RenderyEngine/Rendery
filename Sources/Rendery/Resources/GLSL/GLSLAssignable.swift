/// A type that is assignable to a GLSL uniform.
public protocol GLSLAssignable {

  /// Assigns this value to the GLSL uniform `location` in `program`.
  ///
  /// - Parameters:
  ///   - location: The location of the uniform to which the value should be assigned.
  ///   - program: The program in which the value should be assigned.
  func assign(to location: String, in program: GLSLProgram)

}
