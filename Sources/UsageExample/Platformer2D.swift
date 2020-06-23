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
    var tileModel = Model.sprite(fromImage: tileImage)
    tileModel.pivotPoint.y = 1.0

    // Prepare the scene tree.
    backgroundColor = "#7ec7ff"

    // Create a parent node for to downscale all tiles.
    root3D.createChild(suchThat: { parent in
      parent.scale /= 100.0

      // Create clouds in the background.
      parent.createChild(suchThat: { (clouds: Node) in
        clouds.tags.insert("parallax")
        clouds.model = cloudsModel
        clouds.model!.materials[0].multiply = .color("#cae8ff")
        clouds.translation.z = -10.0
        clouds.scale *= 1.2
      })
      parent.createChild(suchThat: { (clouds: Node) in
        clouds.tags.insert("parallax")
        clouds.model = cloudsModel
        clouds.translation.z = -5.0
        clouds.scale *= 0.8
        clouds.scale.x = -clouds.scale.x
      })

      // Create some distant hills in the background.
      parent.createChild(suchThat: { (ground: Node) in
        ground.tags.insert("parallax")
        ground.model = groundModel
        ground.model!.materials[0].multiply = .color("#a9eaa9")
        ground.translation.y = -200.0
        ground.translation.z = -2.5
      })

      // Create the character.
      characterNode = parent.createChild(suchThat: { (character: Node) in
        character.model = playerModel
        character.model!.pivotPoint.y = 0.0
        character.translation.y = -100.0
      })

      // Create a sequence of tiles that represent the floor.
      parent.createChildren(count: 10, suchThat: { (node: Node, offset: Int) in
        node.model = tileModel
        node.translation.x = (Double(offset) - 4.5) * Double(tileImage.width)
        node.translation.y = -100.0
        node.translation.z = 1.0
      })
    })

    cameraNode = root3D.createChild(suchThat: { (cameraNode: Node) in
      cameraNode.translation.z = 5.0
      cameraNode.camera = Camera(type: .perspective)
    })

    // Subscribe the scene as a frame listener to handle user inputs.
    AppContext.shared.subscribe(frameListener: self)
  }

  override func willMove(from viewport: Viewport, successor: Scene?) {
    AppContext.shared.unsubscribe(frameListener: self)
    root3D.children.forEach({ child in child.removeFromParent() })
  }

  /// The character's node.
  weak var characterNode: Node?

  /// The camera's node.
  weak var cameraNode: Node?

  /// The player's speed.
  let speed = 0.2

  func frameWillRender(currentTime: Milliseconds, delta: Milliseconds) {
    guard let character = characterNode, let camera = cameraNode
      else { return }

    // Move the character.
    if AppContext.shared.inputs.isPressed(key: 68) {
      character.translation.x += Double(delta) * speed
    } else if AppContext.shared.inputs.isPressed(key: 65) {
      character.translation.x -= Double(delta) * speed
    }

    // Track the character's position.
    camera.translation.x = character.sceneTranslation.x

    // Simulate parallax.
    for node in root3D.descendants(.tagged(by: "parallax")) {
      // The farther the node, the smaller its translation should be.
      let factor = 1.0 / -node.translation.z
      node.translation.x = character.translation.x * factor
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
