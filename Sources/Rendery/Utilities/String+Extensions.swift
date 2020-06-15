// MARK: Strideable extensions

extension Strideable {

  internal func clamped(to range: ClosedRange<Self>) -> Self {
    return max(min(self, range.upperBound), range.lowerBound)
  }

}

// MARK: String extensions

extension String {

  /// Returns a sequence that iterates over the lines of this character string.
  internal var lines: LineSequence<String> {
    return LineSequence(collection: self)
  }

}

internal struct LineSequence<S>: Sequence where S: Collection, S.Element == Character {

  internal let collection: S

  internal func makeIterator() -> Iterator {
    return Iterator(collection: collection, start: collection.startIndex)
  }

  internal struct Iterator: IteratorProtocol {

    internal let collection: S

    internal var start: S.Index

    internal mutating func next() -> S.SubSequence? {
      guard start != collection.endIndex
        else { return nil }
      guard let end = collection.suffix(from: start).firstIndex(where: { ch in ch.isNewline })
        else { return nil }
      defer { start = collection.index(after: end) }
      return collection[start ..< end]
    }

  }

}
