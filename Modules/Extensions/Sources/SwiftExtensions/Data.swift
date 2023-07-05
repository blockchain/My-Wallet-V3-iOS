import Foundation

extension Data {

    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    public var toHexString: String { hexEncodedString() }

    public func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef"
        let utf8Digits = Array(hexDigits.utf8)
        return String(unsafeUninitializedCapacity: 2 * count) { ptr -> Int in
            var p = ptr.baseAddress!
            for byte in self {
                p[0] = utf8Digits[Int(byte / 16)]
                p[1] = utf8Digits[Int(byte % 16)]
                p += 2
            }
            return 2 * count
        }
    }
}

extension Data {

    public func decode<T: Decodable>(to type: T.Type, using decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(type, from: self)
    }
}
