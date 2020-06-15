/// A node that can be placed within the hierarchy of a scene tree.
public protocol Node: AnyObject {

  /// The node's name.
  ///
  /// This property can be used to identify a node. You may typically use it in to search for a
  /// particular node in a scene tree.
  var name: String? { get }

  /// The node's tags.
  ///
  /// This property can be used to identify a node. You may typically use it in to search for a set
  /// of nodes in a scene tree.
  var tags: Set<String> { get }

  /// The node's parent.
  var parent: Self? { get }

  /// The node's children.
  var children: [Self] { get }

}

extension Node {

  /// Searches for nodes satisfying the specified criterion in the scene tree rooted by this node.
  ///
  /// - Parameter criterion: The criterion the descendant nodes should satisfy to be returned.
  public func descendants(_ criterion: NodeSearchCriterion<Self>) -> [Self] {
    var results: [Self] = []
    for child in children {
      if criterion.isSatisfied(by: child) {
        results.append(child)
      }
      results.append(contentsOf: child.descendants(criterion))
    }
    return results
  }

  /// Returns whether this node is a descendant of the specified ancestor.
  ///
  /// - Parameter ancestor: The node for which ancestorship shoup be checked.
  public func isDescendant(of ancestor: Self) -> Bool {
    guard let parent = self.parent
      else { return false }
    return (parent === ancestor) || parent.isDescendant(of: ancestor)
  }

}
