#if os(macOS)
import Darwin
#else
import Glibc
#endif

/// A proxy to read the contents of a `.blend` file.
///
/// Blender archives data in the form of a large collection of so-called "data-blocks", which is a
/// generic abstraction of widely different kinds of data (e.g., a mesh, a texture, etc.). Each
/// data-block advertises the type of data it represents and their relationship with other blocks.
///
/// # Global File Structure
///
/// A `.blend` file always start with a file header followed by one are more data-blocks.
///
/// The file header is represented by the 12 first bytes of the file and has information on the
/// the Blender client that produces the file and the machine on which it was saved, namely the
/// pointer size and endianness. This information serves to parse the remainder of the data.
///
/// A block header is a 20 or 24 bytes data structure (depending on the machine's pointer size)
/// that contains:
/// - A 4-characters identifier that indicates the block's type.
/// - The total lenght of the block.
/// - The memory address of the block at the time it was saved.
/// - The block's SDNA index.
/// - The number of structures located in the block.
public final class BlendFile: InitializableFromFile {

  /// Initializes a `.blend` file proxy to read the specified file.
  ///
  /// - Parameter filename: A full or relative path name specifying the `.blend` file.
  ///
  /// - Returns:
  ///   An initialized image or `nil` if the specified file could not be located, or if its content
  ///   could not be decoded.
  public init?(contentsOfFile filename: String) {
    guard let f = FileWrapper(filename: filename)
      else { return nil }
    self.handle = f

    // Make sure the given file is valid.
    guard let header = Header(data: f.read(count: 12))
      else { return nil }
    self.header = header

    // Parse the block headers.
    let archPointerSize = header.arch == .x32 ? 4 : 8
    let blockHeaderSize = 16 + archPointerSize
    while true {
      let buffer = f.read(count: blockHeaderSize)
      guard buffer.count == blockHeaderSize
        else { break }

      var stream = Stream(bytes: buffer[0...])

      // Parse the block header.
      let code = String(stream.consume(4).map({ Character(UnicodeScalar($0)) }))
      let size = Int(stream.consume(Int32.self, endian: header.endian))
      let address = header.arch == .x32
        ? Int(stream.consume(Int32.self, endian: header.endian))
        : Int(stream.consume(Int64.self, endian: header.endian))
      let sdnaIndex = Int(stream.consume(Int32.self, endian: header.endian))
      let structureCount = Int(stream.consume(Int32.self, endian: header.endian))
      let blockHeader = BlockHeader(
        code: code,
        offset: f.tell(),
        size: size,
        address: address,
        sdnaIndex: sdnaIndex,
        structureCount: structureCount)

      // 'ENDB' denotes the end of the file. There's no need to store this block.
      guard blockHeader.code != "ENDB"
        else { break }

      // DNA1 is the index block for the entire blend file.
      if blockHeader.code == "DNA1" {
        self.blockHeaders.insert(blockHeader, at: 0)
        self.dnaIndex = parseDNA(dnaHeader: blockHeader)
      } else {
        self.blockHeaders.append(blockHeader)
      }

      f.seek(offset: blockHeader.size, relative: true)
    }

    // Make sure we found a file index.
    guard self.blockHeaders.first?.code == "DNA1"
      else { return nil }
  }

  /// Parses the file's DNA index.
  ///
  /// - Important: `f` must be positioned at the right after the `DNA1` block header.
  private func parseDNA(dnaHeader: BlockHeader) -> DNAIndex {
    // The block should start with "SDNANAME"
    let data = handle.read(count: dnaHeader.size)
    precondition(data.starts(with: "SDNANAME".ascii), "Malformed index.")

    var stream = Stream(bytes: data[8...])

    // Parse the name array.
    let nameCount = stream.consume(Int32.self, endian: header.endian)
    var names: [String] = []
    for _ in 0 ..< nameCount {
      names.append(stream.consumeCString())
    }
    stream.align(at: 4)
    precondition(stream.consume(4).starts(with: "TYPE".ascii), "Malformed index.")

    // Parse the type array.
    let typeCount = stream.consume(Int32.self, endian: header.endian)
    var types: [String] = []
    for _ in 0 ..< typeCount {
      types.append(stream.consumeCString())
    }
    stream.align(at: 4)
    precondition(stream.consume(4).starts(with: "TLEN".ascii), "Malformed index.")

    // Parse the type lengths.
    var lengths: [Int16] = []
    for _ in 0 ..< typeCount {
      lengths.append(stream.consume(Int16.self, endian: header.endian))
    }
    stream.align(at: 4)
    precondition(stream.consume(4).starts(with: "STRC".ascii), "Malformed index.")

    // Parse the structure array.
    let structureCount = stream.consume(Int32.self, endian: header.endian)
    var structures: [Structure] = []
    for _ in 0 ..< structureCount {
      // Parse the structure's type index.
      let typeIndex = stream.consume(Int16.self, endian: header.endian)

      // Parse the structure's fields (pairs of type and name indices).
      let fieldCount = stream.consume(Int16.self, endian: header.endian)
      var fields: [Field] = []
      for _ in 0 ..< fieldCount {
        fields.append((
          typeIndex: stream.consume(Int16.self, endian: header.endian),
          nameIndex: stream.consume(Int16.self, endian: header.endian)
        ))
      }

      structures.append((typeIndex: typeIndex, fields: fields))
    }

    return DNAIndex(
      names: names,
      types: Array(zip(types, lengths)),
      structures: structures)
  }

  /// The file handle.
  fileprivate let handle: FileWrapper

  /// The file header.
  public let header: Header

  /// A structure that represents the header of `.blend` file.
  public struct Header {

    fileprivate init?(data: [UInt8]) {
      guard (data.count == 12) && Array(data[0 ... 6]) == "BLENDER".ascii
        else { return nil }
      guard let arch = Arch(rawValue: data[7])
        else { return nil }
      guard let endian = Endian(rawValue: data[8])
        else { return nil }

      self.version = (data[9] - 48, data[10] - 48, data[11] - 48)
      self.arch = arch
      self.endian = endian
    }

    /// The version of the Blender client that produced the file.
    public let version: (major: UInt8, minor: UInt8, patch: UInt8)

    /// The size of a pointer for the machine on which the file was saved.
    public let arch: Arch

    /// The endianness of the machine on which the file was saved.
    public let endian: Endian

    /// The total length of the header, taking `arch` into account.
    // public var size: Int { arch == .x32 ? 20 : 24 }

  }

  public enum Arch: UInt8 {

    case x32 = 95

    case x64 = 45

  }

  public enum Endian: UInt8 {

    case little = 118

    case big = 86

  }

  /// The file's block headers.
  fileprivate var blockHeaders: [BlockHeader] = []

  /// A structure that represents the header of a data-block in a `.blend` file.
  fileprivate struct BlockHeader {

    init(
      code: String,
      offset: Int,
      size: Int,
      address: Int,
      sdnaIndex: Int,
      structureCount: Int
    ) {
      self.code = code
      self.offset = offset
      self.size = size
      self.address = address
      self.sdnaIndex = sdnaIndex
      self.structureCount = structureCount
    }

    /// The block's type.
    let code: String

    /// The offset of the block's data (for lazy loading).
    let offset: Int

    /// The total length of the block.
    let size: Int

    /// The block's memory address when it was written to disk.
    let address: Int

    /// The block's SDNA index.
    let sdnaIndex: Int

    /// The number of structures located in the block.
    let structureCount: Int

  }

  /// A structure that represents a data-block in a `.blend` file.
  public struct Block {

    fileprivate init(blend: BlendFile, header: BlockHeader) {
      self.blend = blend
      self.header = header
    }

    /// The type of value that is located in this block.
    public var type: String {
      let structure = blend.dnaIndex.structures[header.sdnaIndex]
      return blend.dnaIndex.types[Int(structure.typeIndex)].repr
    }

    /// The `.blend` file in which this block is stored.
    public unowned let blend: BlendFile

    private let header: BlockHeader

  }

  /// The types (a.k.a. structures) defined in the `.blend` file.
  public var types: [String] { dnaIndex.types.map({ $0.repr }).sorted() }

  /// The file's DNA index.
  fileprivate var dnaIndex: DNAIndex = DNAIndex()

  /// A structure that represents the DNA index of a `.blend` file.
  fileprivate struct DNAIndex {

    init(
      names: [String] = [],
      types: [(repr: String, size: Int16)] = [],
      structures: [Structure] = []
    ) {
      self.names = names
      self.types = types
      self.structures = structures
    }

    let names: [String]

    let types: [(repr: String, size: Int16)]

    let structures: [Structure]

  }

  fileprivate typealias Structure = (typeIndex: Int16, fields: [Field])

  fileprivate typealias Field = (typeIndex: Int16, nameIndex: Int16)

}

/// A wrapper around the contents of a data-block in a `.blend` file.
public class BlenderValue {

  fileprivate init(blend: BlendFile, sdna: Int, data: ArraySlice<UInt8>) {
    self.blend = blend
    self.sdna = sdna
    self.data = data
  }

  public var type: String {
    let structure = blend.dnaIndex.structures[sdna]
    return blend.dnaIndex.types[Int(structure.typeIndex)].repr
  }

  /// A list of the name of each member field contained in this data.
  public var memberNames: [String] {
    let structure = blend.dnaIndex.structures[sdna]
    return structure.fields
      .map({ (field) -> String in
        String(blend.dnaIndex.names[Int(field.nameIndex)].prefix(while: { $0 != "[" }))
      })
      .sorted()
  }

  /// Returns the value of the specified member, wrapped in a proxy that provides a convenient
  /// sugar to chain subscripts.
  ///
  /// This subscript can be used to access an arbitrarily deep member. Rather than explicitly
  /// specifying the expected type after `member(:)`, this subscript allows you to create one
  /// single optional value.
  ///
  /// - Parameter name: The name of the member to access.
  public subscript(name: String) -> SubscriptProxy {
    return SubscriptProxy(value: member(name))
  }

  /// A helper structure that wraps the result of a subscript, providing a more convenient syntax
  /// to chain subscripts.
  public struct SubscriptProxy {

    public subscript(_ name: String) -> SubscriptProxy {
      guard let object = value as? BlenderValue
        else { return SubscriptProxy(value: nil) }
      return object[name]
    }

    /// Attempts to unwrap the proxied data as a value of the specified type.
    ///
    /// - Parameter type: The assumed type of the proxied value.
    public func unwrap<T>(as type: T.Type) -> T? {
      return value as? T
    }

    /// Attempts to unwrap the proxied data as a blender value.
    public var blender: BlenderValue? { value as? BlenderValue }

    /// The proxied data.
    fileprivate var value: Any?

    public static func == <T>(lhs: SubscriptProxy, rhs: T) -> Bool where T: Equatable {
      return lhs.unwrap(as: T.self) == rhs
    }

  }

  /// Returns the value of the specified member, if it can be casted as `T`.
  ///
  /// - Parameter name: The name of the member to access.
  public func member<T>(_ name: String) -> T? {
    return member(name) as? T
  }

  /// Returns the value of the specified member, if it can be casted as `T`.
  ///
  /// - Parameters:
  ///   - name: The name of the member to access.
  ///   - defaultValue: A default value to return in case the member's value can't be retrieved.
  public func member<T>(_ name: String, default defaultValue: T) -> T {
    return (member(name) as? T) ?? defaultValue
  }

  /// Returns the value of the specified member, if any.
  ///
  /// - Parameter name: The name of the member to access.
  public func member(_ name: String) -> Any? {
    let structure = blend.dnaIndex.structures[sdna]

    // Look for a field with the specified member name.
    var offset = 0
    for field in structure.fields {
      var fieldName = blend.dnaIndex.names[Int(field.nameIndex)]
      let fieldType = blend.dnaIndex.types[Int(field.typeIndex)]
      let fieldSize: Int

      var isPointer = false
      var isArray = false
      var count = 1

      // While the DNA index maps type names to their size, the actual size of a field also depends
      // on whether it is stored inline, as a pointer, or as an array. This can be determined by
      // checking the field's name. Pointers starts with a `*` and arrays are suffixed by their
      // number of elements in square brackets (e.g., `name[24]`).
      if fieldName.starts(with: "*") {
        // The member is a pointer.
        fieldSize = (blend.header.arch == .x32) ? 4 : 8
        isPointer = true
      } else if fieldName.starts(with: "(*") {
        // The member is a function pointer.
        fieldSize = (blend.header.arch == .x32) ? 4 : 8
        isPointer = true
      } else if fieldName.last == "]" {
        // The member is an array.
        let comps = fieldName.split(separator: "[")
        count = comps[1...].reduce(1, { result, comp in
          result * Int(comp.dropLast())!
        })

        fieldName = String(comps[0])
        fieldSize = Int(fieldType.size) * count
        isArray = true
      } else {
        fieldSize = Int(fieldType.size)
      }

      assert(!isPointer || !isArray, "\(fieldName) is an array of pointers.")

      if fieldName == name {
        // Extract the data slice that corresponds to the member's representation.
        let slice = data.dropFirst(offset).prefix(fieldSize)
        var stream = Stream(bytes: slice)

        if isPointer {
          let address = blend.header.arch == .x32
            ? Int(stream.consume(Int32.self, endian: blend.header.endian))
            : Int(stream.consume(Int64.self, endian: blend.header.endian))
          guard address != 0
            else { return nil }

          // Check if the address corresponds to a data-block.
          if let blockIndex = blend.blockHeaders.firstIndex(where: { $0.address == address }) {
            let block = blend[blockIndex]
            return block.count == 1
              ? block.first!
              : Array(block)
          }

          // The address can't be retrieved.
          return nil
        }

        // Search for a structure that describes the field's type.
        if let index = blend.dnaIndex.structures.firstIndex(where: { s in
          s.typeIndex == field.typeIndex
        }) {
          if isArray {
            // Return an array of new blender objects.
            return slice
              .split(every: fieldSize)
              .map({ BlenderValue(blend: blend, sdna: index, data: $0) })
          } else {
            // Wrap the member's data into a single new blender objects.
            return BlenderValue(blend: blend, sdna: index, data: slice)
          }
        }

        func parse<T>(_ parser: () -> T) -> Any {
          return isArray
            ? (0 ..< count).map({ _ in parser() })
            : parser()
        }

        switch fieldType.repr {
        case "int64_t", "uint64_t":
          return parse({ stream.consume(Int64.self, endian: blend.header.endian) })

        case "int":
          return parse({ stream.consume(Int32.self, endian: blend.header.endian) })

        case "short":
          return parse({ stream.consume(Int16.self, endian: blend.header.endian) })

        case "float":
          return parse({ () -> Float in
            let bits = stream.consume(UInt32.self, endian: blend.header.endian)
            return Float(bitPattern: bits)
          })

        case "char":
          return String(slice.prefix(while: { $0 != 0 }).map({ Character(UnicodeScalar($0)) }))

        case "void":
          assert(isPointer)

        default:
          break
        }

        // FIXME
        LogManager.main.log(
          "Dismissed the member '\(type).\(fieldName)' while a '.blend file: " +
          "cannot handle data of type '\(fieldType.repr)'.",
          level: .debug)
        return nil
      }

      // Compute the next field's offset.
      offset += fieldSize
    }

    // The member wasn't found.
    return nil
  }

  public unowned let blend: BlendFile

  private let sdna: Int

  private let data: ArraySlice<UInt8>

}

// MARK:- Conformance to Collection

extension BlendFile: Collection {

  public var startIndex: Int { blockHeaders.startIndex }

  public var endIndex: Int { blockHeaders.endIndex }

  public func index(after i: Int) -> Int {
    return blockHeaders.index(after: i)
  }

  public subscript(position: Int) -> Block {
    return Block(blend: self, header: blockHeaders[position])
  }

}

extension BlendFile.Block: Collection {

  public var startIndex: Int { 0 }

  public var endIndex: Int { header.structureCount }

  public func index(after i: Int) -> Int {
    return i + 1
  }

  public subscript(index: Int) -> BlenderValue {
    precondition((0 ..< header.structureCount) ~= index, "Index is out of bounds.")

    let structure = blend.dnaIndex.structures[header.sdnaIndex]
    let size = Int(blend.dnaIndex.types[Int(structure.typeIndex)].size)
    blend.handle.seek(offset: header.offset + index * size)
    let data = blend.handle.read(count: size)

    return BlenderValue(
      blend: blend,
      sdna: header.sdnaIndex,
      data: data[0...])
  }

}

// MARK:- Conformance to CustomStringConvertible

extension BlendFile: CustomStringConvertible {

  public var description: String {
    return String(describing: header)
  }

}

extension BlendFile.Header: CustomStringConvertible {

  public var description: String {
    return "Blend file (v\(version.major).\(version.minor).\(version.patch))"
  }

}

extension BlendFile.Block: CustomStringConvertible {

  public var description: String {
    return "<Block '\(header.code)' at 0x\(String(header.offset, radix: 16))>"
  }

}

extension BlenderValue: CustomStringConvertible {

  public var description: String {
    return "Blender.\(type)()"
  }

}

// MARK:- Utilities

/// A thin wrapper around C's file API.
private class FileWrapper {

  init?(filename: String) {
    guard let handle = fopen(filename, "r")
      else { return nil }
    self.handle = handle
  }

  let handle: UnsafeMutablePointer<FILE>

  func read(count: Int) -> [UInt8] {
    var buffer: [UInt8] = Array(repeating: 0, count: count)
    let readCount = buffer.withUnsafeMutableBytes({ bytes in
      fread(bytes.baseAddress!, MemoryLayout<UInt8>.stride, count, handle)
    })
    return Array(buffer.prefix(readCount))
  }

  func seek(offset: Int, relative: Bool = false) {
    fseek(handle, offset, relative ? SEEK_CUR : SEEK_SET)
  }

  func tell() -> Int {
    return ftell(handle)
  }

  deinit {
    fclose(handle)
  }

}

private extension String {

  var ascii: [UInt8] { map({ $0.asciiValue! }) }

}

private extension UnsafeRawPointer {

  func load<T>(as: T.Type, endian: BlendFile.Endian) -> T where T: FixedWidthInteger {
    switch endian {
    case .little:
      return T(littleEndian: load(as: T.self))
    case .big:
      return T(bigEndian: load(as: T.self))
    }
  }

}

private extension ArraySlice {

  func split(every stride: Int) -> [Self] {
    return (0 ..< count).map({ i in self.dropFirst(i * stride).prefix(stride) })
  }

}

private struct Stream {

  var bytes: ArraySlice<UInt8>

  @discardableResult
  mutating func consume(_ maxLength: Int) -> ArraySlice<UInt8> {
    let prefix = bytes.prefix(maxLength)
    bytes = bytes.dropFirst(maxLength)
    return prefix
  }

  mutating func consume(while predicate: (UInt8) throws -> Bool) rethrows -> ArraySlice<UInt8> {
    let prefix = try bytes.prefix(while: predicate)
    bytes = bytes.dropFirst(prefix.count)
    return prefix
  }

  mutating func consume<T>(_: T.Type, endian: BlendFile.Endian) -> T where T: FixedWidthInteger {
    let value = bytes.withUnsafeBytes({ $0.baseAddress!.load(as: T.self, endian: endian) })
    bytes = bytes.dropFirst(MemoryLayout<T>.stride)
    return value
  }

  mutating func consumeCString() -> String {
    let characters = consume(while: { $0 != 0 })
    bytes = bytes.dropFirst()
    return String(characters.map({ Character(UnicodeScalar($0)) }))
  }

  mutating func align(at byteCount: Int) {
    let m = bytes.startIndex % byteCount
    if m != 0 {
      bytes = bytes.dropFirst(byteCount - m)
    }
  }

}
