/// Returns the address of the specified object as a hex string, for debugging purposes.
internal func address<O>(of object: O) -> String where O: AnyObject {
  let addr = Int(bitPattern: Unmanaged.passUnretained(object).toOpaque())
  return "0x" + String(addr, radix: 16)
}
