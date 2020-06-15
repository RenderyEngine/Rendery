import Rendery

/// The main scene of the 2D platformer game.
final class PlatformerScene: Scene, FrameListener {

  override func willMove(to viewport: Viewport) {
    // Prepare the game's resources.
    let playerImage = provider.fetch(assetOfType: Image.self, named: "platformChar_idle")!
    let playerModel = Model.sprite(fromImage: playerImage)

    let cloudsImage = provider.fetch(assetOfType: Image.self, named: "cloudLayerB1")!
    let cloudsModel = Model.sprite(fromImage: cloudsImage)

    let groundImage = provider.fetch(assetOfType: Image.self, named: "groundLayer1")!
    let groundModel = Model.sprite(fromImage: groundImage)

    let tileImage = provider.fetch(assetOfType: Image.self, named: "platformPack_tile013")!
    let tileModel = Model.sprite(fromImage: tileImage)

    // Prepare the scene tree.
    backgroundColor = "#7ec7ff"

    playerNode = root3D.createChild(suchThat: { (playerNode: Node3D) in
      playerNode.name = "player"

      playerNode.createChild(suchThat: { (clouds: Node3D) in
        clouds.tags.insert("parallax")
        clouds.model = cloudsModel
        clouds.model!.materials[0].multiply = .color("#cae8ff")
        clouds.translation = Vector3(x: 0.0, y: 50.0, z: -20.0)
        clouds.scale *= 1.1
      })

      playerNode.createChild(suchThat: { (clouds: Node3D) in
        clouds.tags.insert("parallax")
        clouds.model = cloudsModel
        clouds.translation.z = -10.0
        clouds.scale *= 0.9
        clouds.scale.x = -1 // .axisAngle = (axis: .unitY, angle: .deg(180.0))
      })

      playerNode.createChild(suchThat: { (ground: Node3D) in
        ground.tags.insert("parallax")
        ground.model = groundModel
        ground.model!.materials[0].multiply = .color("#a9eaa9")
        ground.translation = Vector3(x: 0.0, y: -200.0, z: -5.0)
      })

      playerNode.createChild(suchThat: { (character: Node3D) in
        character.model = playerModel
        character.model!.pivotPoint.y = 0.0
        character.translation.y = -100.0
      })

      playerNode.createChild(suchThat: { (cameraNode: Node3D) in
        cameraNode.translation.z = 750.0
        cameraNode.camera = Camera(type: .perspective, lookingAt: playerNode)
      })
    })

    root3D.createChildren(count: 10, suchThat: { (platformNode: Node3D, offset: Int) in
      platformNode.model = tileModel
      platformNode.model!.pivotPoint.y = 1.0
      platformNode.translation.x = (Double(offset) - 4.5) * Double(tileImage.width)
      platformNode.translation.y = -100.0
    })

    // Subscribe the scene as a frame listener to handle user inputs.
    AppContext.shared.subscribe(frameListener: self)
  }

  override func willMove(from viewport: Viewport, successor: Scene?) {
    AppContext.shared.unsubscribe(frameListener: self)
    root3D.children.forEach({ child in child.removeFromParent() })
  }

  /// The player's node.
  weak var playerNode: Node3D?

  /// The player's speed.
  let speed = 0.2

  func frameWillRender(currentTime: Milliseconds, delta: Milliseconds) {
    guard let playerNode = self.playerNode
      else { return }

    if AppContext.shared.inputs.isPressed(key: 68) {
      playerNode.translation.x += Double(delta) * speed
    } else if AppContext.shared.inputs.isPressed(key: 65) {
      playerNode.translation.x -= Double(delta) * speed
    }

    for node in playerNode.descendants(.tagged(by: "parallax")) {
      // The farther the node, the smaller its translation should be.
      let factor = 1.0 / abs(node.translation.z)
      node.translation.x = playerNode.translation.x * factor
    }
  }

  // The scene's asset provider.
  let provider = LocalAssetProvider(searchPaths: [(path: "Assets/Kenney.nl", recursive: true)])

}

// MARK: Program's entry point

func platformer2D() {
  // Initialize Rendery's engine.
  guard let window = AppContext.shared.initialize(width: 800, height: 500, title: "2D Platformer")
    else { fatalError() }
  defer { AppContext.shared.clear() }

  // Create the game scene and present it in the window's viewport.
  let scene = PlatformerScene()
  window.viewports.first?.present(scene: scene)

  // Run the rendering loop.
  AppContext.shared.targetFrameRate = 60
  AppContext.shared.render()
}
