public protocol DefaultValue {
    associatedtype Value: Codable
    static var value: Value { get }
}

@propertyWrapper
public struct Default<Default: DefaultValue>: Codable {
    public var wrappedValue: Default.Value

    public init(wrappedValue: Default.Value) {
        self.wrappedValue = wrappedValue
    }

    public init(value: Default.Value?) {
        self.wrappedValue = value ?? Default.value
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Default: Equatable where Default.Value: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension KeyedDecodingContainer {

    public func decode<T: DefaultValue>(
        _ type: Default<T>.Type,
        forKey key: KeyedDecodingContainer.Key
    ) throws -> Default<T> {
        // swiftformat:disable:next hoistTry
        Default<T>(value: try decodeIfPresent(T.Value.self, forKey: key))
    }
}

public struct Empty<T: EmptyProtocol & Codable>: DefaultValue {
    public static var value: T { .init() }
}

public protocol EmptyProtocol {
    init()
    var isEmpty: Bool { get }
}

extension String: EmptyProtocol {}
extension Array: EmptyProtocol {}
