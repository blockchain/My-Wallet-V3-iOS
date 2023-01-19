// https://github.com/ollieatkinson/Eumorphic/blob/anything/Sources/Anything/DecodingContainer.swift

public enum DecodingContainer: String {
    case keyed
    case unkeyed
    case singleValue
}

extension Decodable {

    public static var containerType: DecodingContainer {
        do {
            _ = try self.init(from: DecodingContainerDecoder())
            return .singleValue
        } catch let error as DecodingContainerDecoder.Container {
            return error.type
        } catch {
            fatalError("Impossible")
        }
    }
}

public struct DecodingContainerDecoder: Decoder {

    public var codingPath: [CodingKey] { [] }
    public var userInfo: [CodingUserInfoKey: Any] { [:] }

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        throw Container.keyed
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw Container.unkeyed
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw Container.singleValue
    }

    fileprivate enum Container: Error {

        case keyed
        case unkeyed
        case singleValue

        var type: DecodingContainer {
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
}
