// https://github.com/ollieatkinson/Eumorphic/blob/anything/Sources/Anything/AnyCodingKey.swift

public struct AnyCodingKey: CodingKey {

    public var stringValue: String, intValue: Int?

    public init?(intValue: Int) {
        (self.intValue, self.stringValue) = (intValue, String(describing: intValue))
    }

    public init?(stringValue: String) {
        (self.intValue, self.stringValue) = (nil, stringValue)
    }
}

extension AnyCodingKey {

    public init(_ key: some CodingKey) {
        (self.intValue, self.stringValue) = (key.intValue, key.stringValue)
    }

    public init(_ int: Int) {
        self.init(intValue: int)!
    }

    public init(_ string: String) {
        self.init(stringValue: string)!
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(stringValue: value)!
    }
}

extension AnyCodingKey: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.init(intValue: value)!
    }
}
