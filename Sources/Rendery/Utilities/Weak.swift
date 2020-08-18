/// A weak reference wrapper.
public struct WeakRef<T> where T: AnyObject {

  /// Initializes a weak reference wrapper from a reference.
  ///
  /// - Parameter ref: A reference.
  public init(_ ref: T) {
    self.ref = ref
    self._hashValue = ObjectIdentifier(ref).hashValue
  }

  /// The wrapped reference.
  public weak var ref: T?

  /// The hash value of the wrapped reference.
  private let _hashValue: Int

}

extension WeakRef: Equatable where T: Equatable {

  public static func == (lhs: WeakRef, rhs: WeakRef) -> Bool {
    guard let left = lhs.ref, let right = rhs.ref
      else { return false }
    return left == right
  }

}

extension WeakRef: Hashable where T: Hashable {

  public init(_ ref: T) {
    self.ref = ref
    self._hashValue = ref.hashValue
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_hashValue)
  }

}

/// A dictionary that does not retain strong references on its keys.
///
/// This structure is essentially a thin wrapper around a regular dictionary whose keys are
/// instances of `WeakKey<Key>`.
public struct WeakDictionary<Key, Value> where Key: AnyObject & Hashable {

  /// Creates an empty dictionary.
  public init() {
    self.storage = [:]
  }

  /// Creates an empty dictionary with preallocated space for at least the specified number of
  /// elements.
  ///
  /// - Parameter minimumCapacity: The minimum number of key-value pairs that the newly created
  ///   dictionary should be able to store without reallocating its storage buffer.
  public init(minimumCapacity: Int) {
    self.storage = Dictionary(minimumCapacity: minimumCapacity)
  }

  /// Creates a new dictionary from the key-value pairs in the given sequence.
  ///
  /// - Parameter keysAndValues: A sequence of key-value pairs to use for the new dictionary.
  ///   Every key in keysAndValues must be unique.
  public init<S>(uniqueKeysWithValues keysAndValues: S)
    where S : Sequence, S.Element == (Key, Value)
  {
    self.storage = Dictionary(
      uniqueKeysWithValues: keysAndValues.map({ (key, value) in (WeakRef(key), value) }))
  }

  private var storage: [WeakRef<Key>: Value]

  /// Accesses the value associated with the given key for reading and writing.
  ///
  /// - Parameter key: The key the look up in the dictionary.
  public subscript(key: Key) -> Value? {
    get { storage[WeakRef(key)] }
    set { storage[WeakRef(key)] = newValue }
  }

  /// Accesses the value with the given key.
  ///
  /// If the dictionary doesn’t contain the given key, accesses the provided default value as if
  /// the key and default value existed in the dictionary.
  ///
  /// - Parameters:
  ///   - key: The key the look up in the dictionary.
  ///   - defaultValue: The default value to use if key doesn’t exist in the dictionary.
  public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
    return storage[WeakRef(key)] ?? defaultValue()
  }

  /// A collection containing just the keys of the dictionary.
  public var keys: [Key] { indices.map({ self[$0].key }) }

  /// A collection containing just the values of the dictionary.
  public var values: [Value] { indices.map({ self[$0].value }) }

  /// Removes the entries for whose key has been deallocated.
  public mutating func clean() {
    storage = storage.filter({ (key, _) in key.ref != nil })
  }

}

extension WeakDictionary: Collection {

  public typealias Index = Dictionary<WeakRef<Key>, Value>.Index

  public var startIndex: Index {
    return storage.firstIndex(where: { (key, _) in key.ref != nil }) ?? storage.endIndex
  }

  public var endIndex: Index {
    return storage.endIndex
  }

  public func index(after i: Index) -> Index {
    return storage
      .suffix(from: storage.index(after: i))
      .firstIndex(where: { (key, _) in key.ref != nil }) ?? storage.endIndex
  }

  public subscript(i: Index) -> (key: Key, value: Value) {
    let (key, value) = storage[i]
    return (key.ref!, value)
  }

}

extension WeakDictionary: Equatable where Value: Equatable {

  public static func == (lhs: WeakDictionary, rhs: WeakDictionary) -> Bool {
    let l = Array(lhs)
    let r = Array(rhs)
    return Dictionary(uniqueKeysWithValues: l) == Dictionary(uniqueKeysWithValues: r)
  }

}

extension WeakDictionary: Hashable where Value: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(Dictionary(uniqueKeysWithValues: Array(self)))
  }

}

extension WeakDictionary: ExpressibleByDictionaryLiteral {

  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }

}
