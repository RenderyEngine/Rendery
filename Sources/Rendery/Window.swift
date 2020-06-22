import CGLFW
import Dispatch

/// A Rendery window.
public final class Window {

  /// The window's delegate.
  public weak var delegate: WindowDelegate?

  /// A flag that indicates whether the window is the main window.
  public var isMain: Bool { AppContext.shared.mainWindow === self }

  /// A flag that indicates whether the window is a secondary window.
  public var isSecondary: Bool { !isMain }

  /// The window's width, in pixels.
  ///
  /// This property denotes the number of distinct pixels that can be displayed on the window,
  /// horizontally. On some displays (e.g., retina), it may be different than the `width` argument
  /// specified in the window's initializer.
  public fileprivate(set) var width: Int

  /// The window's height, in pixels.
  ///
  /// This property denotes the number of distinct pixels that can be displayed on the window,
  /// vertically. On some displays (e.g., retina), it may be different than the `width` argument
  /// specified in the window's initializer.
  public fileprivate(set) var height: Int

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
  /// Setting this flag to `true` will immediately notify the window's delegate, which may decide
  /// to cancel the close request by setting it back to `false`.
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
  public var cursorPosition: Vector2 {
    get {
      var screenWidth: Int32 = 0
      var screenHeight: Int32 = 0
      glfwGetWindowSize(handle, &screenWidth, &screenHeight);
      let screenSize = Vector2(x: Double(screenWidth), y: Double(screenHeight))

      // Get the cursor position.
      var cursorPosition: Vector2 = .zero
      glfwGetCursorPos(handle, &cursorPosition.x, &cursorPosition.y)
      return cursorPosition / screenSize
    }
  }

  // MARK: Initialization

  /// Initializes a window.
  ///
  /// - Parameters:
  ///   - width: The window's width, in pixels.
  ///   - height: The window's height, in pixels.
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

    // TODO: This callback gets called when a Unicode character is input, but not the individual
    // key events that led to the production of the unicode character. It will probably be very
    // useful to implement text fields.
    // glfwSetCharCallback(handle, windowCharCallback)
  }

  /// The pointer to the GLFW's window.
  internal let handle: OpaquePointer?

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

    // Clear the screen buffer with the window's background color.
    glClearColor(backgroundColor)
    glClear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)

    // Render the viewports.
    for viewport in viewports {
      // Draw the scene (if any) in each defined viewport.
      if let scene = viewport.scene {
        render(scene: scene, on: viewport, generation: generation)
      }
    }

    // Restore the default viewport.
    glViewport(0, 0, Int32(width), Int32(height))

    // Swap the front and back buffers.
    glfwSwapBuffers(handle)
  }

  /// Renders the specified scene on the specified viewport.
  private func render(scene: Scene, on viewport: Viewport, generation: UInt64) {
    // Compute the actual region of the rendering area designated by the viewport.
    let region = viewport.region.scaled(x: Double(width), y: Double(height))
    glViewport(region: region)

    // Enable the scissor test so that rendering can only occur in the viewport's region.
    glScissor(region: region)
    glEnable(GL.SCISSOR_TEST)

    // Clear the scene's background.
    glClearColor(scene.backgroundColor)
    glClear(GL.COLOR_BUFFER_BIT)

    if let pov = viewport.pointOfView  {
      // Apply the transform constraints on the point of view so that all camera properties are
      // up to date before computing the view-projection matrix.
      scene.updateConstraints(on: pov, generation: generation)

      if let vpMatrix = viewport.viewProjectionMatrix {
        // Collect the scene's light sources to compute lighting.
        let lightNodes = scene.root3D.descendants(.satisfying({ $0.light != nil }))

        // Render the scene tree.
        scene.root3D.render(
          vpMatrix: vpMatrix,
          ambient: scene.ambientLight,
          lightNodes: lightNodes)
      }
    }

    glDisable(GL.SCISSOR_TEST)
  }

  // MARK: Deinitialization

  /// Immediately closes the window, invalidating its handle.
  internal func close() {
    guard !isClosed
      else { return }

    delegate?.didClose(window: self)
    glfwDestroyWindow(handle)
    isClosed = true
  }

  deinit {
    close()
  }

}

// MARK:- Responder chain

extension Window: InputResponder {

  public var nextResponder: InputResponder? { nil }

  public func respondToKeyPress(with event: KeyEvent) {
    delegate?.didKeyPress(window: self, event: event)
  }

  public func respondToKeyRelease(with event: KeyEvent) {
    delegate?.didKeyRelease(window: self, event: event)
  }

  public func respondToMousePress(with event: MouseEvent) {
    delegate?.didMousePress(window: self, event: event)
  }

  public func respondToMouseRelease(with event: MouseEvent) {
    delegate?.didMouseRelease(window: self, event: event)
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
  window.delegate?.willClose(window: window)
}

private func windowSizeCallback(handle: OpaquePointer?, width: Int32, height: Int32) {
  guard let window = windowFrom(handle: handle)
    else { return }

  var actualWidth: Int32 = 0
  var actualHeight: Int32 = 0
  glfwGetFramebufferSize(handle, &actualWidth, &actualHeight)

  window.width = Int(actualWidth)
  window.height = Int(actualHeight)
  window.delegate?.didResize(window: window)
}

private func windowFocusCallback(handle: OpaquePointer?, hasFocus: Int32) {
  guard let window = windowFrom(handle: handle)
    else { return }

  if (hasFocus == GLFW_TRUE) {
    // If focus changes from one window to another, the first callback is for the window that
    // lost it and the second for the window that received it.
    AppContext.shared.activeWindow = nil
    window.delegate?.didLostFocus(window: window)
  } else {
    AppContext.shared.activeWindow = window
    window.delegate?.didReceiveFocus(window: window)
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

  // Update the input state.
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

  // Get the cursor position.
  let cursorPosition = window.cursorPosition

  // Determine the viewport in which the event should be dispatched.
  let responder: InputResponder = window.viewports.first(where: { (viewport) -> Bool in
    viewport.region.contains(cursorPosition)
  }) ?? window

  // Dispatch the event to the first responder for mouse events.
  let event = MouseEvent(
    button: Int(button),
    cursorPosition: cursorPosition,
    modifiers: KeyModifierSet(fromGLFW: modifiers),
    firstResponder: responder,
    timestamp: DispatchTime.now().uptimeNanoseconds / 1_000_000)

 if action == GLFW_RELEASE {
   responder.respondToMouseRelease(with: event)
 } else {
   responder.respondToMousePress(with: event)
 }
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
