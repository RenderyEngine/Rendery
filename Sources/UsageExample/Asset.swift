import Foundation
import Rendery

public protocol InitializableFromFile {

  init?(contentsOfFile: String)

}

extension Rendery.Image: InitializableFromFile {
}

public final class LocalAssetProvider {

  public init(searchPaths: [(path: String, recursive: Bool)]) {
    self.searchPaths = searchPaths
  }

  public convenience init() {
    self.init(searchPaths: [(path: ".", recursive: true)])
  }

  public var searchPaths: [(path: String, recursive: Bool)]

  public func fetch<Asset>(
    assetOfType assetType: Asset.Type,
    named assetName: String,
    withExtension ext: String? = nil
  ) -> Asset? where Asset: InitializableFromFile {
    for (path, recursive) in searchPaths {
      if let asset = fetch(
        assetOfType: assetType.self,
        named: assetName,
        withExtension: ext,
        from: path,
        recursive: recursive)
      {
        return asset
      }
    }

    return nil
  }

  public func fetch<Asset>(
    assetOfType assetType: Asset.Type,
    named assetName: String,
    withExtension ext: String? = nil,
    from path: String,
    recursive: Bool = true
  ) -> Asset? where Asset: InitializableFromFile {
    let prefix = URL(fileURLWithPath: path)

    if recursive {
      let enumerator = FileManager.default.enumerator(atPath: path)
      while let file = enumerator?.nextObject() as? String {
        let url = URL(fileURLWithPath: file)
        if url.lastPathComponent.starts(with: assetName) &&
          (ext == nil || url.pathExtension == ext)
        {
          return Asset(contentsOfFile: prefix.appendingPathComponent(file).path)
        }
      }
    } else {
      guard let files = try? FileManager.default.contentsOfDirectory(atPath: path)
        else { return nil }

      for file in files {
        let url = URL(fileURLWithPath: file)
        if url.lastPathComponent.starts(with: assetName) &&
          (ext == nil || url.pathExtension == ext)
        {
          return Asset(contentsOfFile: prefix.appendingPathComponent(file).path)
        }
      }
    }

    return nil
  }

}
