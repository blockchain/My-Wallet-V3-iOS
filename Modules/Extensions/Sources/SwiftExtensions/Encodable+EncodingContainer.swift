// https://github.com/ollieatkinson/Eumorphic/blob/anything/Sources/Anything/EncodingContainer.swift

public enum EncodingContainer: String {
    case keyed
    case unkeyed
    case singleValue
}

extension Encodable {

    public var containerType: EncodingContainer { ContainerTypeEncoder().container(self) }
}

private enum ContainerType: Error {
    case keyed, unkeyed, singleValue
}

extension ContainerType {
    var type: EncodingContainer {
        switch self {
        case .keyed:
            return .keyed
        case .unkeyed:
            return .unkeyed
        case .singleValue:
            return .singleValue
        }
    }
}

public struct ContainerTypeEncoder: Encoder, UnsupportedEncoderValues {

    public func container(_ this: some Encodable) -> EncodingContainer {
        do {
            try this.encode(to: ContainerTypeEncoder())
            return .singleValue
        } catch let error as ContainerType {
            return error.type
        } catch {
            fatalError("Impossible")
        }
    }
}

extension ContainerTypeEncoder {
    public func container<Key>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> where Key: CodingKey { KeyedEncodingContainer(KeyedContainer<Key>()) }
    public func unkeyedContainer() -> UnkeyedEncodingContainer { UnkeyedContainer() }
    public func singleValueContainer() -> SingleValueEncodingContainer { SingleValueContainer() }
}

extension ContainerTypeEncoder {
    public struct KeyedContainer<Key>: UnsupportedEncoderValues where Key: CodingKey {}
}

extension ContainerTypeEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    public func encodeNil(forKey key: Key) throws { throw ContainerType.keyed }
    public mutating func encode(_ value: some Encodable, forKey key: Key) throws { throw ContainerType.keyed }
}

extension ContainerTypeEncoder {
    public struct SingleValueContainer: UnsupportedEncoderValues {}
}

extension ContainerTypeEncoder.SingleValueContainer: SingleValueEncodingContainer {
    public func encodeNil() throws { throw ContainerType.singleValue }
    public func encode(_ value: some Encodable) throws { throw ContainerType.singleValue }
}

extension ContainerTypeEncoder {
    public struct UnkeyedContainer: UnsupportedEncoderValues { public var count: Int = 0 }
}

extension ContainerTypeEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    public mutating func encodeNil() throws { throw ContainerType.unkeyed }
    public mutating func encode(_ value: some Encodable) throws { throw ContainerType.unkeyed }
}

private func unsupported(_ function: String = #function) -> Never {
    fatalError("\(function) isn't supported by ContainerTypeEncoder")
}

private protocol UnsupportedEncoderValues {
    var codingPath: [CodingKey] { get }
    var userInfo: [CodingUserInfoKey: Any] { get }
}

extension UnsupportedEncoderValues {
    public var codingPath: [CodingKey] { unsupported() }
    public var userInfo: [CodingUserInfoKey: Any] { unsupported() }
}

extension ContainerTypeEncoder.KeyedContainer {
    public mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey { unsupported() }
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer { unsupported() }
    public func superEncoder() -> Encoder { unsupported() }
    public func superEncoder(forKey key: Key) -> Encoder { unsupported() }
}

extension ContainerTypeEncoder.UnkeyedContainer {
    public mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey { unsupported() }
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer { unsupported() }
    public func superEncoder() -> Encoder { unsupported() }
}
