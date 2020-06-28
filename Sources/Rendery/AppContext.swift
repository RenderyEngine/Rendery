import CGLFW
import Dispatch

/// A centralized object that gathers the global state of a Rendery application.
public final class AppContext {

  /// The singleton instance.
  public private(set) static var shared = AppContext()

  /// A flag that indicates whether the application context is initialized.
  public private(set) var isInitialized = false

  /// Initializes the application context.
  ///
  /// Calling this method has no effect if the context is already initialized, and will return the
  /// current main window.
  ///
  /// - Parameters:
  ///   - width: The width of the main window, in pixels.
  ///   - height: The height of the main window, in pixels.
  ///   - title: The title of the main window.
  ///
  /// - Returns: The main window associated with the application context once initialized.
  @discardableResult
  public func initialize(width: Int, height: Int, title: String) -> Window? {
    guard !isInitialized else {
      LogManager.main.log("Application context is already initialized.", level: .warning)
      return mainWindow
    }

#if os(OSX)
    // On macOS, `glfwInit()` changes the current directory to the `Contents/Resources` directory
    // of the application's bundle, if present. This can be disabled with the following hint.
    glfwInitHint(GLFW_COCOA_CHDIR_RESOURCES, GLFW_FALSE)
#endif

    // Initialize GLFW.
    guard glfwInit() == GLFW_TRUE else {
      LogManager.main.log("Failed to initialize GLFW.", level: .error)
      return nil
    }

    // Configure OpenGL context.
    glfwDefaultWindowHints()
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)

#if os(OSX)
    // macOS requires to enable forward compatibility.
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)
#endif

    isInitialized = true

    // Create the main window.
    guard let mainWindow = createWindow(width: width, height: height, title: title) else {
      LogManager.main.log("Failed to create a main window.", level: .error)
      clear()
      return nil
    }
    activeWindow = mainWindow

    // Set the main window the current OpenGL context, so that the user can load data onto the GPU
    // (e.g., textures, meshes, etc.). This context will be shared among all secondary windows.
    glfwMakeContextCurrent(mainWindow.handle)

    // Disable V-Sync.
    glfwSwapInterval(0)

    // Enable blending and specifies how OpenGL should handle transparency. This requires textures
    // to be loaded with premultiplied alpha (i.e., (αR,αG,αB,α) rather than (R,G,B,α)).
    glEnable(GL.BLEND)
    glBlendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA)
    // glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA) // <- without premultiplied alpha

    // Enable depth testing.
    // FIXME: It's been suggested that depth testing should be removed when drawing 2D sprites with
    // some transparency, but it is needed to render 3D. It feature could be exposed as a property
    // of the app context.
    glEnable(GL.DEPTH_TEST)
    glDepthFunc(GL.LESS)

    // Enable stencil testing.
    glEnable(GL.STENCIL_TEST)
    glStencilFunc(GL.NOTEQUAL, 1, 0xff)
    glStencilOp(GL.KEEP, GL.KEEP, GL.REPLACE)

    return mainWindow
  }

  /// Clears the application context.
  public func clear() {
    // Reset the singleton, causing its deinitializer to execute and dropping all held references.
    AppContext.shared = AppContext()
  }

  /// The application context's font manager.
  public let fontManager = FontManager()

  /// The windows created with this application context.
  ///
  /// - Note: The order in which windows appear in the array is irrelevant.
  public private(set) var windows: [Window] = []

  /// The main window linked to this application context.
  ///
  /// An application context designates one window has its main window, which is created when it is
  /// initialized. All other windows are considered secondary windows. The application context is
  /// cleared when its main window closes, closing all secondary windows and dropping out of the
  /// rendering loop.
  public var mainWindow: Window? { windows.first }

  /// The window that currently has focus.
  public internal(set) weak var activeWindow: Window?

  /// Creates a new window.
  ///
  /// - Parameters:
  ///   - width: The window's width, in pixels.
  ///   - height: The window's height, in pixels.
  ///   - title: The window's title.
  public func createWindow(width: Int, height: Int, title: String) -> Window? {
    guard let window = Window(
      width: width,
      height: height,
      title: title,
      sharingContextWith: mainWindow)
    else { return nil }

    // Register the newly created window.
    windows.append(window)
    return window
  }

  /// The ordered set of frame listeners subscribed to the app context.
  public private(set) var frameListeners: [FrameListener] = []

  /// Subscribes the specified frame listener, if not already subscribed.
  ///
  /// This method has no effect if `frameListener` has already been subscribed. This guarantees
  /// that a frame listener cannot be called twice for the same frame event.
  ///
  /// - Parameter frameListener: The frame listener to subscribe.
  ///
  /// - Returns: The index of the frame listener in the subscription set. The index will point to
  ///   the last position of the subscription set if the listener was not already subscribed,
  ///   otherwise, it will refer to its current position.
  @discardableResult
  public func subscribe<L>(frameListener: L) -> Int where L: FrameListener {
    if let index = frameListeners.firstIndex(where: { fl in fl === frameListener }) {
      return index
    } else {
      frameListeners.append(frameListener)
      return frameListeners.count - 1
    }
  }

  /// Creates a frame listener with the given closure and subscribes it.
  ///
  /// - Parameter frameWillRender: The closure implementing the listener's behavior.
  ///
  /// - Returns: The index of the frame listener in the subscription set.
  @discardableResult
  public func subscribe(
    frameListener frameWillRender: @escaping FrameListenerClosure.Function
  ) -> Int {
    let listener = FrameListenerClosure(frameWillRender)
    frameListeners.append(listener)
    return frameListeners.count - 1
  }

  /// Unsubscribes the specified frame listener.
  ///
  /// - Parameter frameListener: The frame listener to unsubscribe.
  ///
  /// - Returns: `frameListener` if it was subscribed, otherwise, `nil`.
  @discardableResult
  public func unsubscribe<L>(frameListener: L) -> L? where L: FrameListener {
    guard let index = frameListeners.firstIndex(where: { fl in fl === frameListener })
      else { return nil }
    frameListeners.remove(at: index)
    return frameListener
  }

  /// A structure that keeps track of the user inputs.
  public var inputs: InputState = InputState()

  // MARK: Renderer settings

  /// The number of frames per second Rendery should try to render.
  ///
  /// This property instructs Rendery to try to run each rendering cycle at the specified frame
  /// rate. If it is left unassigned, then Rendery will try to render frames as fast as possible.
  ///
  /// Setting this property does not guarantee that the specified frame rate will be achieved.
  /// While Rendery will not go above, it might fall below if it has too much to compute between
  /// two frames. Hence, you should not rely on this property to update your logic. Instead, you
  /// should use the `currentTime` argument that is provided to frame listeners.
  public var targetFrameRate: Int?

  /// The width of the lines that are drawn as `Mesh.PrimitiveType.lines`.
  ///
  /// This property should be used for debugging purposes only. The actual range of widths that can
  /// be supported is driver-dependent, which may lead to inconsistent results. If you need to use
  /// lines as part of a scene, consider creating a mesh with `Mesh.polyline(segments:thickness:)`.
  public var lineWidth: Double = 1.0 {
    didSet { glLineWidth(Float(lineWidth)) }
  }

  /// A flag that indicates whether blending is enabled.
  internal var isBlendingEnabled: Bool = true {
    didSet {
      if isBlendingEnabled {
        glEnable(GL.BLEND)
      } else {
        glDisable(GL.BLEND)
      }
    }
  }

  /// A flag that indicates whether transparent textures have their alpha-channel premultiplied.
  internal var isAlphaPremultiplied: Bool = true {
    didSet {
      if isAlphaPremultiplied {
        glBlendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA)
      } else {
        glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
      }
    }
  }

  /// A flag that indicates whether depth testing is enabled.
  internal var isDepthTestingEnabled: Bool = true {
    didSet {
      if isDepthTestingEnabled {
        glEnable(GL.DEPTH_TEST)
      } else {
        glDisable(GL.DEPTH_TEST)
      }
    }
  }

  /// Execute the specified closure and restore all renderer settings to their value before the
  /// closure ran.
  internal func restoreSettingsAfter<Result>(_ block: () -> Result) -> Result {
    let wasBlendingEnabled = isBlendingEnabled
    let wasAlphaPremultiplied = isAlphaPremultiplied
    let wasDepthTestingEnabled = isDepthTestingEnabled

    defer {
      isBlendingEnabled = wasBlendingEnabled
      isAlphaPremultiplied = wasAlphaPremultiplied
      isDepthTestingEnabled = wasDepthTestingEnabled
    }

    return block()
  }

  // MARK: Rendering loop

  /// A flag that indicates whether the rendering loop should stop before the next frame.
  public var shouldStopRendering = false

  /// Starts Rendery's rendering loop.
  ///
  /// The method starts the rendering loop and does not return until it is halted. Any subscribed
  /// frame listener will be at the beginning of each frame, allowing them to update the logic of
  /// your application before the frame renders.
  ///
  /// - Parameter condition: A closure that is called at the beginning of each cycle and returns
  ///   `true` if the rendering loop should continue, or `false` otherwise. If the parameter is set
  ///   to `nil`, then the rendering loop continues until `shouldStopRendering` is set to `true` or
  ///   the main window is closed.
  public func render(while condition: (() -> Bool)? = nil) {
    guard isInitialized else {
      LogManager.main.log("Application context is not already initialized.", level: .error)
      return
    }

    assert(mainWindow != nil)
    shouldStopRendering = false
    LogManager.main.log("Rendering loop started.", level: .debug)

    /// The last time at which the frame listener has been called.
    var lastUpdateTime: Milliseconds = DispatchTime.now().uptimeNanoseconds / 1_000_000

    while(!shouldStopRendering && (condition == nil || condition!())) {
      // Save the time at which the render cycle started.
      let renderCycleStart = DispatchTime.now().uptimeNanoseconds / 1_000_000

      // Poll user inputs (must be called on the main thread).
      glfwPollEvents()

      // Notify all frame listeners.
      let now = DispatchTime.now().uptimeNanoseconds / 1_000_000
      for listener in frameListeners {
        listener.frameWillRender(currentTime: Milliseconds(now), delta: now - lastUpdateTime)
      }
      lastUpdateTime = now

      // Render each window.
      var windowIndex = 0
      while windowIndex < windows.count {
        let window = windows[windowIndex]

        // Remove the windows that have been closed.
        guard glfwWindowShouldClose(window.handle) == GLFW_FALSE else {
          // If the window is main, immediately clear the context and drop out of the loop.
          if window === mainWindow {
            clear()
            return
          }

          windows.remove(at: windowIndex)
          window.close()
          continue
        }

        // While GLFW windows have to be created on the main thread, they should be renderable on
        // any thread. Therefore, one optimization might be to spawn a thread for each window,
        // rather than rendering them in sequence. However, this also means that any user code that
        // gets executed in response to the rendering should by thread-aware.

        window.render(generation: renderCycleStart)
        windowIndex = windowIndex + 1
      }

      // Wait to cap the frame rate if a target FPS has been set, whose period is longer than the
      // the time it took to render the frame and let the listeners update the scene.
      if let fps = targetFrameRate {
        let threshold = UInt64(1000.0 / Double(fps))
        var delta = DispatchTime.now().uptimeNanoseconds / 1_000_000 - renderCycleStart
        var req = timespec(tv_sec: 0, tv_nsec: 1_000_000)
        while delta < threshold {
          nanosleep(&req, nil)
          delta = DispatchTime.now().uptimeNanoseconds / 1_000_000 - renderCycleStart
        }
      }
    }
  }

  // MARK: Internal API

  private init() {
    glfwSetErrorCallback { (error, description) in
      LogManager.main.log(
        "GLFW issued the following error: (\(error)) \(String(cString: description!))",
        level: .error)
    }
  }

  /// The application context's graphics resource manager.
  internal let graphicsResourceManager = GraphicsResourceManager()

  deinit {
    // Close all windows.
    for window in windows {
      window.close()
    }

    // Unload all managed resources.
    graphicsResourceManager.unloadAllResources()

    // Terminate GLFW.
    glfwTerminate()
  }

}
