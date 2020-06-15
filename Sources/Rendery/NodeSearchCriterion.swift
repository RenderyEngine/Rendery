/// A search criterion to locate a node in a scene tree.
public enum NodeSearchCriterion<N> where N: Node {

  /// A node named after the specified name.
  case named(String)

  /// A node whose set of tags contains the specified tags.
  case tagged(by: [String])

  /// A node whose set of tags contains the specified tag.
  public static func tagged(by tag: String) -> NodeSearchCriterion {
    return .tagged(by: [tag])
  }

  /// A node satisfying the specified predicate.
  case satisfying((N) -> Bool)

  /// The conjunction of two criteria.
  indirect case both(NodeSearchCriterion, NodeSearchCriterion)

  /// This disjunction of two criteria.
  indirect case either(NodeSearchCriterion, NodeSearchCriterion)

  /// Returns whether the specified node satisfies this criterion.
  public func isSatisfied(by node: N) -> Bool {
    switch self {
    case .named(let name):
      return node.name == name
    case .tagged(let tags):
      return node.tags.isSuperset(of: tags)
    case .satisfying(let predicate):
      return predicate(node)
    case .both(let lhs, let rhs):
      return lhs.isSatisfied(by: node) && rhs.isSatisfied(by: node)
    case .either(let lhs, let rhs):
      return lhs.isSatisfied(by: node) || rhs.isSatisfied(by: node)
    }
  }

}

extension NodeSearchCriterion: CustomStringConvertible {

  public var description: String {
    switch self {
    case .named(let name):
      return ".(named: \(name))"
    case .tagged(let tags):
      return ".(by: \(tags))"
    case .satisfying:
      return ".satisfying([Function])"
    case .both(let lhs, let rhs):
      return ".both(\(lhs), \(rhs))"
    case .either(let lhs, let rhs):
      return ".either(\(lhs), \(rhs))"
    }
  }

}
