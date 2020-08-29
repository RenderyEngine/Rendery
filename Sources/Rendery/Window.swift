import CGLFW
import Dispatch

/// A Rendery window.
public final class Window {

  /// The pointer to the GLFW's window.
  internal let handle: OpaquePointer?

  /// A flag that indicates whether the window is the main window.
  public var isMain: Bool { AppContext.shared.mainWindow === self }

  /// A flag that indicates whether the window is a secondary window.
  public var isSecondary: Bool { !isMain }

  /// The window's width, in pixels.
  ///
  /// This property relates to the width of the window's frame buffer and denotes the number of
  /// distinct pixels that can be displayed on the window, horizontally. On some devices, such as
  /// retina displays, it may be larger than the window's `screenWidth`.
  public fileprivate(set) var width: Int

  /// The window's height, in pixels.
  ///
  /// This property relates to the width of the window's frame buffer and denotes the number of
  /// distinct pixels that can be displayed on the window, vertically. On some devices, such as
  /// retina displays, it may be larger than the window's `screenHeight`.
  public fileprivate(set) var height: Int

  /// The window's width, in screen coordinates.
  public fileprivate(set) var screenWidth: Int

  /// The window's height, in screen coordinates.
  public fileprivate(set) var screenHeight: Int

  /// The window's title.
  public let title: String

  /// The color of the window's background.
  public var backgroundColor: Color = .blue

  /// The window's viewports.
  public private(set) var viewports: [Viewport] = []

  /// Adds a new viewport to the window.
  ///
  /// - Parameter region: The region of the window designated by the viewport, in normalized
  ///   coordinates (i.e., expressed in values between `0` and `1`).
  @discardableResult
  public func createViewport(
    region: Rectangle = Rectangle(origin: .zero, dimensions: .unitScale)
  ) -> Viewport {
    let viewport = Viewport(target: self, region: region)
    viewports.append(viewport)
    return viewport
  }

  /// Removes the specified viewport from the window.
  ///
  /// This method has no effect if the specified viewport is not attached to the window.
  ///
  /// - Parameter viewport: The viewport to remove.
  public func removeViewport(_ viewport: Viewport) {
    viewports.removeAll(where: { $0 === viewport })
  }

  /// A flag that indicates whether the window is closed.
  public private(set) var isClosed = false

  /// A flag that indicates whether the window should close before the next frame is rendered.
  ///
  /// Setting this flag to `true` will immediately call `willClose`, which may decide to cancel the
  /// close request by setting it back to `false`.
  public var shouldClose: Bool {
    get {
      return isClosed || (glfwWindowShouldClose(handle) == GLFW_FALSE)
    }

    set {
      guard !isClosed else {
        LogManager.main.log("Ignored property change on closed window.", level: .debug)
        return
      }

      glfwSetWindowShouldClose(handle, GLFW_TRUE)
    }
  }

  /// The position of the cursor, in normalized window coordinates.
  ///
  /// Normalized window coordinates range from `0.0` to `1.0` on both axes, where `(0.0, 0.0)`
  /// deisgnates the window's top-left corner.
  public fileprivate(set) var cursorPosition: Vector2 = .zero

  /// The mode with which cursor motion inputs are handled.
  public var cursorMotionMode: CursorMotionMode = .normal {
    didSet {
      switch cursorMotionMode {
      case .normal  : glfwSetInputMode(handle, GLFW_CURSOR, GLFW_CURSOR_NORMAL)
      case .managed : glfwSetInputMode(handle, GLFW_CURSOR, GLFW_CURSOR_DISABLED)
      case .hidden  : glfwSetInputMode(handle, GLFW_CURSOR, GLFW_CURSOR_HIDDEN)
      }
    }
  }

  /// A mode of cursor motion inputs handling.
  public enum CursorMotionMode {

    /// The cursor is represented as an icon (e.g., a regular arrow).
    case normal

    /// The cursor is hidden and its motion is managed by Rendery.
    ///
    /// This mode is typcially used to implement motion based camera control. The cursor is assumed
    /// to be placed in the center.
    case managed

    /// The cursor's icon is hidden, but the cursor otherwise behave normally.
    case hidden

  }

  // MARK: Initialization

  /// Initializes a window.
  ///
  /// - Parameters:
  ///   - width: The window's width, in screen coordinates.
  ///   - height: The window's height, in screen coordinates.
  ///   - title: The window's title.
  ///   - other: An another window whose OpenGL context should be shared.
  internal init?(width: Int, height: Int, title: String, sharingContextWith other: Window?) {
    guard AppContext.shared.isInitialized else {
      LogManager.main.log("Application context is not initialized.", level: .error)
      return nil
    }

    // Create the GLFW window.
    self.title = title
    self.handle = glfwCreateWindow(Int32(width), Int32(height), self.title, nil, other?.handle)
    guard self.handle != nil else {
      LogManager.main.log("Failed to initialize GLFW window.", level: .error)
      return nil
    }

    self.screenWidth = width
    self.screenHeight = height

    // Get the actual window resolution. On some displays (e.g., retina), it may differ from the
    // width and height that were given arguments.
    var actualWidth: Int32 = 0
    var actualHeight: Int32 = 0
    glfwGetFramebufferSize(self.handle, &actualWidth, &actualHeight)
    self.width = Int(actualWidth)
    self.height = Int(actualHeight)

    // Create a default viewport covering the entire window.
    self.createViewport()

    // Register callbacks.
    glfwSetWindowCloseCallback(handle, windowCloseCallback)
    glfwSetWindowSizeCallback(handle, windowSizeCallback)
    glfwSetWindowFocusCallback(handle, windowFocusCallback)
    glfwSetKeyCallback(handle, windowKeyCallback)
    glfwSetMouseButtonCallback(handle, windowMouseButtonCallback)
    glfwSetCursorPosCallback(handle, windowCursorPosCallback)

    // TODO: This callback gets called when a Unicode character is input, but not the individual
    // key events that led to the production of the unicode character. It will probably be very
    // useful to implement text fields.
    // glfwSetCharCallback(handle, windowCharCallback)

    AppContext.shared.subscribe(frameListener: frameRateObserver)
  }

  // MARK: Event handling

  /// A callback that is called when the window is about to close.
  public var willClose: (() -> Void)?

  /// A callback that is called when the window closed.
  public var didClose: (() -> Void)?

  /// A callback that is called when the window has been resized.
  public var didResize: (() -> Void)?

  /// A callback that is called when the window received focus.
  public var didReceiveFocus: (() -> Void)?

  /// A callback that is called when the window lost focus.
  public var didLoseFocus: (() -> Void)?

  /// A callback that is called when the window recieved a key press event.
  public var didKeyPress: ((KeyEvent) -> Void)?

  /// A callback that is called when the window recieved a key release event.
  public var didKeyRelease: ((KeyEvent) -> Void)?

  /// A callback that is called when the window recieved a mouse press event.
  public var didMousePress: ((MouseEvent) -> Void)?

  /// A callback that is called when the window recieved a mouse release event.
  public var didMouseRelease: ((MouseEvent) -> Void)?

  // MARK: Debugging

  /// The current frame rate of the window.
  public var frameRate: Int { frameRateObserver.frameRate }

  /// The window's frame rate observer.
  private var frameRateObserver = FrameRateObserver()

  /// A frame listener that computes the average frame rate over a short time window.
  private class FrameRateObserver: FrameListener {

    private var start: Milliseconds = 0

    var frameCount = 1

    var frameRate = 0

    func frameWillRender(currentTime: Milliseconds, delta: Milliseconds) {
      // Report the average frame rate every 10 frames.
      if frameCount % 10 == 0 {
        frameRate = Int(1.0 / Double(currentTime - start) * 10000)
        start = currentTime
        frameCount = 0
      }
      frameCount += 1
    }

  }

  // MARK: Rendering

  /// Renders this window.
  ///
  /// This method executes the last step of the rendering cycle by rendering the viewports. It is
  /// called by the application context after the frame listeners have been notified.
  ///
  /// - Parameter generation: The generation number of the rendering loop. This number serves to
  ///   invalidate some internal caches.
  internal func render(generation: UInt64) {
    // Set the window as the current OpenGL context.
    glfwMakeContextCurrent(handle)

    let appContext = AppContext.shared

    // Clear the screen buffers. Note that default values have to be explicitly reset for `glClear`
    // to have an effect (see https://stackoverflow.com/questions/58640953).
    glClearColor(backgroundColor.linear(gamma: appContext.gamma))
    glStencilMask(0xff)
    glClear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT)

    // Render the viewports.
    for viewport in viewports {
      // Draw the scene (if any) in each defined viewport.
      if let scene = viewport.scene {
        // Update the scene's arrays of model and light nodes if necessary.
        if scene.shoudUpdateModelAndLightNodeCache {
          scene.updateModelAndLightNodeCache()
        }

        // Update transform constraints.
        for node in scene.constraintCache.keys {
          scene.updateConstraints(on: node, generation: generation)
        }

        // Compute the actual region of the rendering area designated by the viewport.
        let region = viewport.region.scaled(x: Double(width), y: Double(height))
        glViewport(region: region)

        // Enable the scissor test so that rendering can only occur in the viewport's region.
        glScissor(region: region)
        glEnable(GL.SCISSOR_TEST)
        defer { glDisable(GL.SCISSOR_TEST) }

        // Clear the render context's cache.
        appContext.renderContext.modelViewProjMatrices.removeAll(keepingCapacity: true)
        appContext.renderContext.normalMatrices.removeAll(keepingCapacity: true)

        // Send the scene through the viewport's render pipeline.
        viewport.renderPipeline.render(
          scene: scene,
          to: viewport,
          in: appContext.renderContext)

        // Prepare the render state to draw UI elements.
        appContext.renderContext.isBlendingEnabled = true
        appContext.renderContext.isDepthTestEnabled = false

        // Configure the UI view renderer.
        viewRenderer.dimensions = region.dimensions
        viewRenderer.penPosition = .zero
        viewRenderer.defaultFontFace = appContext.defaultFontFace

        // Draw the scene's HUD.
        viewport.hud.draw(in: &viewRenderer)

        if viewport.showsFrameRate {
          viewRenderer.penPosition = Vector2(x: 16.0, y: 16.0)
          TextView(verbatim: "\(frameRate)", face: appContext.defaultFontFace)
            .setting(color: Color.red)
            .draw(in: &viewRenderer)
        }
      }
    }

    // Restore the default viewport.
    glViewport(0, 0, Int32(width), Int32(height))

    // Swap the front and back buffers.
    glfwSwapBuffers(handle)
  }

  private var viewRenderer = ViewRenderer()

  // MARK: Deinitialization

  /// Immediately closes the window, invalidating its handle.
  internal func close() {
    guard !isClosed
      else { return }

    didClose?()
    glfwDestroyWindow(handle)
    isClosed = true
  }

  deinit {
    AppContext.shared.unsubscribe(frameListener: frameRateObserver)
    close()
  }

}

// MARK:- Responder chain

extension Window: InputResponder {

  public var nextResponder: InputResponder? { nil }

  public func respondToKeyPress(with event: KeyEvent) {
    didKeyPress?(event)
  }

  public func respondToKeyRelease(with event: KeyEvent) {
    didKeyRelease?(event)
  }

  public func respondToMousePress(with event: MouseEvent) {
    didMousePress?(event)
  }

  public func respondToMouseRelease(with event: MouseEvent) {
    didMouseRelease?(event)
  }

}

// MARK:- Callback functions

/// Retrieves a window instance from its handle.
private func windowFrom(handle: OpaquePointer?) -> Window? {
  return handle != nil
    ? AppContext.shared.windows.first(where: { win in win.handle == handle })
    : nil
}

private func windowCloseCallback(handle: OpaquePointer?) {
  guard let window = windowFrom(handle: handle)
    else { return }
  window.willClose?()
}

private func windowSizeCallback(handle: OpaquePointer?, width: Int32, height: Int32) {
  guard let window = windowFrom(handle: handle)
    else { return }

  window.screenWidth = Int(width)
  window.screenHeight = Int(height)

  var actualWidth: Int32 = 0
  var actualHeight: Int32 = 0
  glfwGetFramebufferSize(handle, &actualWidth, &actualHeight)

  window.width = Int(actualWidth)
  window.height = Int(actualHeight)
  window.didResize?()
}

private func windowFocusCallback(handle: OpaquePointer?, hasFocus: Int32) {
  guard let window = windowFrom(handle: handle)
    else { return }

  if (hasFocus == GLFW_TRUE) {
    AppContext.shared.activeWindow = window
    window.didReceiveFocus?()
  } else {
    // If focus changes from one window to another, the first callback is for the window that
    // lost it and the second for the window that received it.
    AppContext.shared.activeWindow = nil
    window.didLoseFocus?()
  }
}

/// The window keyboard callback.
///
/// - Parameters:
///   - handle: An opaque pointer to the GLFW window handle.
///   - key: A layout-independent key token (e.g. `GLFW_KEY_A`) that designates the key that was
///     pressed or released. Tokens are named after the standard US keyboard layout.
///   - scancode: A platform (or machine)-specific code that uniquely identifies a key. It can be
///     used to identify keys that do not have any token value. `key` will be assigned to
///     `GLFW_KEY_UNKNOWN` for such keys.
///   - action: The even type (`GLFW_RELEASE`, `GLFW_PRESS` or `GLFW_REPEAT`).
///   - modifiers: A bitmask identify which key modifiers are currently pressed, where all
///     individual bits can be identified by the constants `GLFW_MOD_*`.
private func windowKeyCallback(
  handle: OpaquePointer?,
  key: Int32,
  scancode: Int32,
  action: Int32,
  modifiers: Int32
) {
  guard let window = windowFrom(handle: handle)
    else { return }

  // Update the input state of the application context.
  let code = key != GLFW_KEY_UNKNOWN
    ? Int(key)
    : 1 << 63 | Int(scancode)
  if action & (GLFW_PRESS | GLFW_REPEAT) != 0 {
    AppContext.shared.inputs.keyPressed.insert(code)
  } else {
    AppContext.shared.inputs.keyPressed.remove(code)
  }

  // Get the key symbol.
  let symbol = glfwGetKeyName(key, scancode).map(String.init(cString:))

  // FIXME: The following code implies that viewports are always first responders for key events.
  // This is okay for now, but we'll have to change this once we implement text input fields.
  let responder: InputResponder = window.viewports.first ?? window

  // Dispatch the event to the first responder for key events.
  let event = KeyEvent(
    isRepeat: action == GLFW_REPEAT,
    modifiers: KeyModifierSet(fromGLFW: modifiers),
    code: code,
    symbol: symbol,
    firstResponder: responder,
    timestamp: DispatchTime.now().uptimeNanoseconds / 1_000_000)

  if action == GLFW_RELEASE {
    responder.respondToKeyRelease(with: event)
  } else {
    responder.respondToKeyPress(with: event)
  }
}

/// The window mouse button callback.
///
/// - Parameters:
///   - handle: An opaque pointer to the GLFW window handle.
///   - button: A code that identifies the mouse button that was pressed or released.
///   - action: The even type (`GLFW_RELEASE` or `GLFW_PRESS`).
///   - modifiers: A bitmask identify which key modifiers are currently pressed, where all
///     individual bits can be identified by the constants `GLFW_MOD_*`.
private func windowMouseButtonCallback(
  handle: OpaquePointer?,
  button: Int32,
  action: Int32,
  modifiers: Int32
) {
  guard let window = windowFrom(handle: handle)
    else { return }

  // Update the input state of the application context.
  let code = Int(button)
  if action & GLFW_PRESS != 0 {
     AppContext.shared.inputs.mouseButtonPressed.insert(code)
   } else {
     AppContext.shared.inputs.mouseButtonPressed.remove(code)
   }

  // Identify the first responder.
  let cursorPosition = window.cursorPosition
  var responder: InputResponder?

  // Determine the viewport in which the event should be dispatched.
  let viewport = window.viewports.first(where: { (viewport) -> Bool in
    viewport.region.contains(cursorPosition)
  })

  // Check if the event occured on a view that can become responder.
  if let hud = viewport?.hud, hud.subview != nil {
    let scale = Vector2(x: Double(window.width), y: Double(window.height))
    let point = (cursorPosition - viewport!.region.origin) * scale
    var view = hud.view(at: point)

    while view != nil {
      if let resp = view as? InputResponder {
        responder = resp
        break
      }
      view = view?.container
    }
  }

  if responder == nil {
    responder = viewport ?? window
  }

  // Dispatch the event to the first responder for mouse events.
  let event = MouseEvent(
    button: code,
    cursorPosition: cursorPosition,
    modifiers: KeyModifierSet(fromGLFW: modifiers),
    firstResponder: responder,
    timestamp: DispatchTime.now().uptimeNanoseconds / 1_000_000)

 if action == GLFW_RELEASE {
   responder!.respondToMouseRelease(with: event)
 } else {
   responder!.respondToMousePress(with: event)
 }
}

private func windowCursorPosCallback(handle: OpaquePointer?, x: Double, y: Double) {
  guard let window = windowFrom(handle: handle)
    else { return }

  window.cursorPosition.x = x / Double(window.screenWidth)
  window.cursorPosition.y = y / Double(window.screenHeight)
}

private extension KeyModifierSet {

  init(fromGLFW modifiers: Int32) {
    self.rawValue = 0

    if (modifiers & GLFW_MOD_SHIFT) == GLFW_MOD_SHIFT {
      insert(.shift)
    }
    if (modifiers & GLFW_MOD_CONTROL) == GLFW_MOD_CONTROL {
      insert(.control)
    }
    if (modifiers & GLFW_MOD_ALT) == GLFW_MOD_ALT {
      insert(.option)
    }
    if (modifiers & GLFW_MOD_SUPER) == GLFW_MOD_SUPER {
      insert(.command)
    }
    if (modifiers & GLFW_MOD_CAPS_LOCK) == GLFW_MOD_CAPS_LOCK {
      insert(.capsLock)
    }
    if (modifiers & GLFW_MOD_NUM_LOCK) == GLFW_MOD_NUM_LOCK {
      insert(.numLock)
    }
  }

}
