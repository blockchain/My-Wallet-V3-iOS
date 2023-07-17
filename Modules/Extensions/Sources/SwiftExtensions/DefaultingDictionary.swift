@dynamicMemberLookup
public struct DefaultingDictionary<Key, Value> where Key: Hashable {

    public private(set) var dictionary: [Key: Value]
    public var `default`: (Key) -> Value

    public init(
        _ dictionary: [Key: Value] = [:],
        default ƒ: @escaping (Key) -> Value
    ) {
        self.dictionary = dictionary
        self.default = ƒ
    }

    public init(
        _ dictionary: [Key: Value] = [:],
        default ƒ: @escaping @autoclosure () -> Value
    ) {
        self.init(dictionary) { _ in ƒ() }
    }
}

extension DefaultingDictionary {

    public subscript<A>(dynamicMember path: KeyPath<[Key: Value], A>) -> A {
        dictionary[keyPath: path]
    }

    public subscript(key: Key) -> Value {
        get { dictionary[key] ?? self.default(key) }
        set { dictionary[key] = newValue }
    }

    public subscript() -> [Key: Value] {
        get { dictionary }
        set { dictionary = newValue }
    }
}

extension Dictionary {

    @inlinable
    public func defaulting(to ƒ: @escaping (Key) -> Value) -> DefaultingDictionary<Key, Value> {
        .init(self, default: ƒ)
    }

    @inlinable
    public func defaulting(to ƒ: @escaping @autoclosure () -> Value) -> DefaultingDictionary<Key, Value> {
        .init(self, default: { _ in ƒ() })
    }
}

extension DefaultingDictionary: LazySequenceProtocol, LazyCollectionProtocol {}

extension DefaultingDictionary: Collection {

    public typealias Base = [Key: Value]

    public var startIndex: Base.Index {
        dictionary.startIndex
    }

    public var endIndex: Base.Index {
        dictionary.endIndex
    }

    public var indices: Base.Indices {
        dictionary.indices
    }

    public subscript(position: Base.Index) -> Base.Element {
        dictionary[position]
    }

    public func index(after i: Base.Index) -> Base.Index {
        dictionary.index(after: i)
    }

    public func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index {
        dictionary.index(i, offsetBy: distance)
    }

    public func index(_ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index) -> Base.Index? {
        dictionary.index(i, offsetBy: distance, limitedBy: limit)
    }

    public func formIndex(after i: inout Base.Index) {
        dictionary.formIndex(after: &i)
    }

    public func makeIterator() -> Base.Iterator {
        dictionary.makeIterator()
    }

    public func distance(from start: Base.Index, to end: Base.Index) -> Int {
        dictionary.distance(from: start, to: end)
    }

    public var count: Int {
        dictionary.count
    }
}
