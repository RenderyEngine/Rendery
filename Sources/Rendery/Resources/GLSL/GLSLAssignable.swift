/// A type that is assignable to a GLSL uniform.
public protocol GLSLAssignable {

  /// Assigns this value to the GLSL uniform `location` in `program`.
  ///
  /// - Parameters:
  ///   - name: The name of the variable to which the value should be assigned.
  ///   - program: The program in which the value should be assigned.
  func assign(to name: String, in program: GLSLProgram)

}
