/// The abstraction of a viewport.
///
/// A viewport designates a region of a rendering surface (e.g., a window) that displays a scene's
/// contents, as observed from a node holding a camera (a.k.a. a point of view). If two viewports
/// overlap, the order in which they are registered in the window is used to determine the one that
/// obscures the other.
///
/// The region of a viewport is measured in normalized coordinates, so that it can be resized along
/// the rendering surface. It is used after the scene coordinates have been projected by the camera
/// to obtain an object's the final position on the rendering surface. The actual dimensions of the
/// viewport define an aspect ratio. Cameras maintain their own aspect ratio, that should typically
/// matches that of the viewport to avoid any kind of distortion.
public final class Viewport {

  /// Initializes a viewport with the region of the rendering surface it designates.
  ///
  /// - Parameters:
  ///   - target: The rendering surface that is the target for the rendering.
  ///   - region: The region of the rendering surface designated by the viewport, in normalized
  ///     coordinates (i.e., expressed in values between `0` and `1`).
  internal init(target: Window, region: Rectangle) {
    self.target = target
    self.region = region
  }

  /// The viewport's delegate.
  public weak var delegate: ViewportDelegate?

  /// The viewport's target.
  public unowned let target: Window

  /// The viewport's region.
  public var region: Rectangle

  /// The scene currently presented by the viewport.
  public private(set) var scene: Scene?

  /// The node from which the scene is viewed for rendering.
  ///
  /// This property should be assigned to a node with an attached camera. The node will provide the
  /// position and orientation of the camera, while the camera itself will be used to set rendering
  /// parameters such as the projection type, field of view and viewing frustum.
  ///
  /// The scene will not be rendered if `pointOfView` is `nil`, or if it has no camera attached.
  public weak var pointOfView: Node3D?

  /// Sets the specified scene as the viewport's rendered contents.
  ///
  /// The new scene immediately replaces the current scene, if one exists.
  ///
  /// - Parameters:
  ///   - newScene: The scene to present.
  ///   - pointOfView: A node representing the point from which the scene is viewed. If unassigned,
  ///     this method will attempt to use the first node with an attached camera it can find.
  public func present(scene newScene: Scene, from pointOfView: Node3D? = nil) {
    scene?.willMove(from: self, successor: newScene)
    newScene.willMove(to: self)

    scene = newScene
    self.pointOfView = pointOfView ?? newScene.root3D
      .descendants(.satisfying({ node in node.camera != nil })).first
    if self.pointOfView == nil {
      LogManager.main.log("Presented scene has no point of view.", level: .debug)
    }
  }

  /// Dimisses the scene currently presented by the viewport, if any.
  public func dismissScene() {
    scene?.willMove(from: self, successor: nil)
    scene = nil
  }

}

extension Viewport: InputResponder {

  public var nextResponder: InputResponder? {
    guard target.viewports.last !== self
      else { return target }

    let i = target.viewports.firstIndex(where: { $0 === self })!
    return target.viewports[i + 1]
  }

  public func respondToKeyPress<E>(with event: E) where E : KeyEventProtocol {
    if let delegate = self.delegate {
      delegate.didKeyPress(viewport: self, event: event)
    } else {
      nextResponder?.respondToKeyPress(with: event)
    }
  }

  public func respondToKeyRelease<E>(with event: E) where E : KeyEventProtocol {
    if let delegate = self.delegate {
      delegate.didKeyRelease(viewport: self, event: event)
    } else {
      nextResponder?.respondToKeyRelease(with: event)
    }
  }

  public func respondToMousePress<E>(with event: E) where E : MouseEventProtocol {
    if let delegate = self.delegate {
      delegate.didMousePress(viewport: self, event: event)
    } else {
      nextResponder?.respondToMousePress(with: event)
    }
  }

  public func respondToMouseRelease<E>(with event: E) where E : MouseEventProtocol {
    if let delegate = self.delegate {
      delegate.didMouseRelease(viewport: self, event: event)
    } else {
      nextResponder?.respondToMouseRelease(with: event)
    }
  }

}
