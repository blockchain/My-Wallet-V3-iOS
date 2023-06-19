import Foundation

public struct AnyType: Hashable, CustomStringConvertible {

    public let type: Any.Type
    public let description: String

    let _decode: ((Any, AnyDecoderProtocol) throws -> Any)?

    public init<T>(_ type: T.Type) {
        self.type = type
        self.description = .init(reflecting: T.self)
        self._decode = nil
    }

    public static func == (lhs: AnyType, rhs: AnyType) -> Bool {
        lhs.type == rhs.type
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension AnyType {

    public init<T: Decodable>(_ type: T.Type) {
        self.type = type
        self.description = .init(reflecting: T.self)
        self._decode = { data, decoder in try decoder.decode(T.self, from: data) }
    }

    public func decode(_ json: Any, using decoder: AnyDecoderProtocol = AnyDecoder()) throws -> Any {
        try _decode.or(throw: "`\(description)` is not Decodable")(json, decoder)
    }
}
