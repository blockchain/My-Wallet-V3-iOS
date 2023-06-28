import AnyCoding
import Foundation

extension Tag.Event where Self: L {
    public typealias JSON = TaggedJSON<Self, Self>
}

extension TaggedJSON where From == To {

    @_disfavoredOverload
    public init(_ data: AnyJSON = .empty, in context: Tag.Context = [:]) {
        self.init(data, as: From(String(reflecting: From.self).tagTypeToId), in: context)
    }
}

@dynamicMemberLookup
public struct TaggedJSON<From: L & I, To: L & I>: Codable, Hashable, AnyJSONConvertible {

    private let from: From
    private let to: To

    private var context: Tag.Context
    private var data: AnyJSON = nil

    public func any() -> Any? {
        data.any
    }

    public func toJSON() -> AnyJSON {
        data
    }

    public init(_ data: AnyJSON, as type: From, in context: Tag.Context = [:]) where From == To {
        (self.from, self.to) = (type, type)
        self.data = data
        self.context = context
    }

    public init(_ data: AnyJSON, from: From, to: To, in context: Tag.Context = [:]) {
        self.from = from
        self.to = to
        self.data = data
        self.context = context
    }

    public init(from decoder: Decoder) throws {
        self.from = From(String(reflecting: From.self).tagTypeToId)
        self.to = To(String(reflecting: To.self).tagTypeToId)
        self.context = decoder.userInfo[.context] as? Tag.Context ?? [:]
        self.data = try AnyJSON(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
    }

    @_disfavoredOverload
    public subscript<Next: L>(dynamicMember keyPath: KeyPath<To, Next>) -> TaggedJSON<From, Next> {
        get { TaggedJSON<From, Next>(data, from: from, to: to[keyPath: keyPath], in: context) }
        set { (data, context) = (newValue.data, newValue.context) }
    }

    subscript(keyPath: KeyPath<To, some L>) -> Any? {
        get { try? data[path() + [to[keyPath: keyPath][].name]] }
        set { try? data[path() + [to[keyPath: keyPath][].name]] = newValue }
    }

    public subscript(id: String) -> TaggedJSON<From, To> where To: I_blockchain_db_collection {
        get { TaggedJSON(data, from: from, to: to, in: context + [to.id: id]) }
        set { self = newValue }
    }

    @_disfavoredOverload
    public subscript(id: String) -> TaggedJSON<From, To> {
        get { TaggedJSON(data, from: from, to: to, in: context + [to: id]) }
        set { self = newValue }
    }

    public func `in`(context: Tag.Context) -> TaggedJSON {
        TaggedJSON(data, from: from, to: to, in: self.context + context)
    }

    public subscript() -> Any? {
        get { try? data[path()] }
        set { try? data[path()] = newValue }
    }

    @_disfavoredOverload
    public subscript<Value: Decodable>() -> Value? {
        try? self(Value.self)
    }

    public func callAsFunction<T: Decodable>(_ as: T.Type = T.self) throws -> T {
        try data[path()].decode(T.self, using: BlockchainNamespaceDecoder())
    }

    private func path() throws -> [String] {
        try to[].lineage
            .reversed()
            .drop(while: { tag in tag.parent != from[] })
            .flatMap { node -> [String] in
                guard let collectionId = node["id"], Tag.Reference.volatileIndices.doesNotContain(collectionId) else {
                    return [node.name]
                }
                return try [
                    node.name,
                    (context[collectionId] as? String).or(throw: "No context for \(collectionId)")
                ]
            }
    }
}

extension TaggedJSON {

    @_disfavoredOverload
    public subscript(dynamicMember keyPath: KeyPath<To, some L>) -> Any? {
        get { self[keyPath] }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_boolean>) -> Bool? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_string>) -> String? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_integer>) -> Int? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_number>) -> Double? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_tag>) -> Tag.Event? {
        get { try? self[keyPath].decode(Tag.Reference.self) }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_url>) -> URL? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_date>) -> Date? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_enum>) -> Tag? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_data>) -> Data? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array>) -> [AnyJSON]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_strings>) -> [String]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_tags>) -> [Tag.Reference]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_integers>) -> [Int]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_numbers>) -> [Double]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_maps>) -> [[String: AnyJSON]]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_urls>) -> [URL]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_booleans>) -> [Bool]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_array_of_dates>) -> [Date]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<To, some L & I_blockchain_db_type_map>) -> [String: AnyJSON]? {
        get { try? self[keyPath].decode() }
        set { self[keyPath] = newValue }
    }
}
