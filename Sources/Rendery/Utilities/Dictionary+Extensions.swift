extension Dictionary {

  mutating func value(forKey key: Key, caching cachedValue: () -> Value) -> Value {
    if let value = self[key] {
      return value
    } else {
      let value = cachedValue()
      self[key] = value
      return value
    }
  }

  mutating func value(forKey key: Key, caching cachedValue: @autoclosure () -> Value) -> Value {
    return value(forKey: key, caching: cachedValue)
  }

}
