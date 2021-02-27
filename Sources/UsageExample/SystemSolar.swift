import Rendery
import GL
import Glibc

class SystemSolar: Scene {

  override init() {
    super.init()

    backgroundColor = "#000000"

    let solarRadius: Double = 50.0

    // planet = [name, radius, solar_dist, polar_angle, revolution, texture_path]
    let listPlanet = [["Mercury", sizePlanet(s: solarRadius, p: 11440), distPlanet(s: solarRadius, d: 35.791), 0.0, 88.0, "/img/mercury_tex.jpeg"],
                      ["Venus", sizePlanet(s: solarRadius, p: 15052), distPlanet(s: solarRadius, d: 45.82), 0.0, 225.0, "/img/venus_tex.jpg"],
                      ["Earth", sizePlanet(s: solarRadius, p: 16371), distPlanet(s: solarRadius, d: 64.96), 0.0, 365.0, "/img/earth_tex.jpg"],
                      ["Mars", sizePlanet(s: solarRadius, p: 12390), distPlanet(s: solarRadius, d: 72.79), 0.0, 687.0, "/img/mars_tex.jpg"],
                      ["Jupiter", sizePlanet(s: solarRadius, p: 69911), distPlanet(s: solarRadius, d: 97.85), 0.0, 1380.0, "/img/jupiter_tex.jpg"],
                      ["Saturn", sizePlanet(s: solarRadius, p: 58232), distPlanet(s: solarRadius, d: 143.40), 0.0, 3585.0, "/img/saturn_tex.jpg"],
                      ["Uranus", sizePlanet(s: solarRadius, p: 25362), distPlanet(s: solarRadius, d: 227.10), 0.0, 4660.0, "/img/uranus_tex.jpg"],
                      ["Neptune", sizePlanet(s: solarRadius, p: 24622), distPlanet(s: solarRadius, d: 350.50), 0.0, 6225.0, "/img/neptune_tex.jpg"]
                     ]

    // Create a sphere for the solar
    let solar = root.createChild()
    solar.name = "Solar"
    solar.model = Model(
      meshes: [.sphere(segments: 100, rings: 100, radius: solarRadius)],
      materials: [Material()])
    // Apply a texture to the solar
    solar.model?.materials[0].diffuse = .texture(ImageTexture(image: Image(contentsOfFile: "Sources"+"/img/solar_tex.jpg")!, wrapMethod: .repeat))
    // Modify its color
    //solar.model?.materials[0].multiply = .color(Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5))
    solar.translation.x = 0.0
    solar.translation.y = 0.0
    solar.translation.z = 0.0

    // Create a sphere for each planet
    for planet in listPlanet {
      var planetAngle: Double = (planet[3] as! Double)
      let p = root.createChild()
      p.name = (planet[0] as! String)
      p.model = Model(
        meshes: [.sphere(segments: 50, rings: 50, radius: (planet[1] as! Double))],
      materials: [Material()])
      // Apply a texture to each planet
      p.model?.materials[0].diffuse = .texture(ImageTexture(image: Image(contentsOfFile: "Sources"+(planet[5] as! String))!, wrapMethod: .repeat))
      // p.translation.z = -x because x = -z
      p.translation.z = -(self.P2C(r: (planet[2] as! Double), theta: planetAngle)).0
      // p.translation.x = -y because y = -x
      p.translation.x = -(self.P2C(r: (planet[2] as! Double), theta: planetAngle)).1

      // Rotate the planets on them self
      var a = Angle(radians: 0)
      AppContext.shared.subscribe(frameListener: { _, delta in
        a += .rad(Double(delta) / 1000)
        p.rotation = Quaternion(axis: .unitY, angle: a)
      })

      // Change the planets' position
      AppContext.shared.subscribe(frameListener: { _, delta in
        // Compute polar coordinates and compote (x,y) cartesian coordinates to update planets' position
        var newTheta = self.updatePostion(revo: (planet[4] as! Double), angle: planetAngle)
        // p.translation.z = -x because x = -z
        p.translation.z = -(self.P2C(r: (planet[2] as! Double), theta: newTheta)).0
        // p.translation.x = -y because y = -x
        p.translation.x = -(self.P2C(r: (planet[2] as! Double), theta: newTheta)).1
        planetAngle = newTheta

      })

    }

    // Define the lighting of the scene
    let lightNode = root.createChild()
    lightNode.light = Light(type: .directional)
    lightNode.light?.isCastingShadow = true
    lightNode.translation = Vector3(x: 10.0, y: 5.0, z: 7.5)
    lightNode.constraints.append(LookAtConstraint(target: root))


    // Define the user view (camera)
    let cameraNode = root.createChild()
    cameraNode.name = "Camera"
    cameraNode.camera = Camera()
    cameraNode.camera?.farDistance = 5000.0
    cameraNode.translation = Vector3(x: 750.0, y: 65, z: 0.0)
    cameraNode.constraints.append(LookAtConstraint(target: root))
  }

  // Update the polar angle of each planet
  func updatePostion(revo: Double, angle: Double) -> Double {
    let newAngle = angle + (360/(revo*50))
    return (newAngle.truncatingRemainder(dividingBy: 360.0))
  }

  // Convert polar coordinates to cartesian
  func P2C(r: Double, theta: Double) -> (Double, Double) {
    let x = r * cos(theta)
    let y = r * sin(theta)
    return (x,y)
  }

  // Convert cartesian coordinates to polar
  func C2P(x: Double, y: Double) -> (Double, Double) {
    let r = sqrt(pow(x,2) + pow(y,2))
    let theta = atan(y/x)*(180/Double.pi)
    return (r,theta)
  }

  // Real planet scale
  func sizePlanet(s: Double, p: Double) -> Double {
    return (p*s)/696340
  }

  // Real distance solar - planets
  func distPlanet(s: Double, d: Double) -> Double {
    let d_m = d*pow(10.0, 6)
    return -1*(d_m/696340)
  }
}

// Call sampleScene() to build the entire scene
func sampleScene() {

  // Initialize Rendery's engine.
  guard let window = AppContext.shared.initialize(width: 1500, height: 800, title: "Solar System")
    else { fatalError() }
  //defer { AppContext.shared.clear() } #TODO: bug under linux

  // Create the game scene and present it in the window's viewport.
  let scene = SystemSolar()
  window.viewports.first?.present(scene: scene)

  // Run the rendering loop.
  AppContext.shared.targetFrameRate = 60
  AppContext.shared.render()
}
