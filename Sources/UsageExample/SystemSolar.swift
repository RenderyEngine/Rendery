import Rendery
import GL

class SystemSolar: Scene {

  override init() {
    super.init()

    backgroundColor = "#000000"

    let listPlanet = [["Mercury", 1.0, -15.0],
                      ["Venus", 2.0, -19.0],
                      ["Earth", 1.8, -24.0],
                      ["Mars", 1.1, -30.0],
                      ["Jupiter", 3.0, -35.0],
                      ["Saturn", 2.9, -43.0],
                      ["Uranus", 2.3, -51.0],
                      ["Neptune", 2.3, -59.0]
                     ]

     let solar = root.createChild()
     solar.name = "Solar"
     solar.model = Model(
       meshes: [.sphere(segments: 50, rings: 50, radius: 10.0)],
       materials: [.white])
     solar.model?.materials[0].diffuse = .color(.yellow)
     solar.translation.z = 0.0

     var a = Angle(radians: 0)
     AppContext.shared.subscribe(frameListener: { _, delta in
       a += .rad(Double(delta) / 1000)
       solar.rotation = Quaternion(axis: .unitY, angle: a)
     })

    for planet in listPlanet {
      print(planet)
      let p = root.createChild()
      p.name = (planet[0] as! String)
      p.model = Model(
        meshes: [.sphere(segments: 50, rings: 50, radius: (planet[1] as! Double))],
        materials: [.white])
      p.model?.materials[0].diffuse = .color(.yellow)
      p.translation.z = (planet[2] as! Double)

      var a = Angle(radians: 0)
      AppContext.shared.subscribe(frameListener: { _, delta in
        a += .rad(Double(delta) / 1000)
        p.rotation = Quaternion(axis: .unitY, angle: a)
      })

      var sign = 1.0
      var f : Bool = false
      AppContext.shared.subscribe(frameListener: { _, delta in
        if (p.translation.z) == -60.0 {
            f = true
        }
        if (p.translation.z) == 60.0 {
            f = false
        }
        if (f) {
          p.translation.z += 1
        } else {
          p.translation.z -= 1
        }
      })
    }

    let lightNode = root.createChild()
    lightNode.light = Light(type: .directional)
    lightNode.light?.isCastingShadow = true
    lightNode.translation = Vector3(x: 0.0, y: 5.0, z: 7.5)
    lightNode.constraints.append(LookAtConstraint(target: root))

    var sign = -1.0
    AppContext.shared.subscribe(frameListener: { _, delta in
      if abs(lightNode.translation.y) < 5.0 {
        lightNode.translation.y += sign * Double(delta) / 500
      } else {
        lightNode.translation.y = sign * 4.9
        sign = -sign
      }
    })

    let cameraNode = root.createChild()
    cameraNode.name = "Camera"
    cameraNode.camera = Camera()
    cameraNode.camera?.farDistance = 100.0
    cameraNode.translation = Vector3(x: 100.0, y: 0, z: 0.0)
    cameraNode.constraints.append(LookAtConstraint(target: root))
  }

}


func sampleScene() {
  // Initialize Rendery's engine.
  guard let window = AppContext.shared.initialize(width: 800, height: 500, title: "sampleScene")
    else { fatalError() }
  //defer { AppContext.shared.clear() }

  // Create the game scene and present it in the window's viewport.
  let scene = SystemSolar()
  window.viewports.first?.present(scene: scene)

  // Run the rendering loop.
  AppContext.shared.targetFrameRate = 60
  AppContext.shared.render()
}
