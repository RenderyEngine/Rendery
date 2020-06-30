internal enum GLSL {

  struct Vec2: Equatable {

    var x: Float
    var y: Float

  }

  struct Vec3: Equatable {

    var x: Float
    var y: Float
    var z: Float

  }

  struct Vec4: Equatable {

    var x: Float
    var y: Float
    var z: Float
    var w: Float

  }

  struct Mat3: Equatable {

    var m00: Float
    var m10: Float
    var m20: Float

    var m01: Float
    var m11: Float
    var m21: Float

    var m02: Float
    var m12: Float
    var m22: Float

  }

  struct Mat4: Equatable {

    var m00: Float
    var m10: Float
    var m20: Float
    var m30: Float

    var m01: Float
    var m11: Float
    var m21: Float
    var m31: Float

    var m02: Float
    var m12: Float
    var m22: Float
    var m32: Float

    var m03: Float
    var m13: Float
    var m23: Float
    var m33: Float

  }

}
