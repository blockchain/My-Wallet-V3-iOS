import AnyCoding
import Extensions

extension Compute {

    struct Comparison: ComputeKeyword, Equatable {

        enum Operation: String, CodingKey, Decodable {
            case match
            case equal
            case greater, greater_or_equal, less, less_or_equal
        }

        struct Operands: Decodable {
            let lhs, rhs: AnyJSON
        }

        var operation: Operation
        var lhs, rhs: AnyJSON

        init(from decoder: Decoder) throws {
            let name = try [String: CodableVoid](from: decoder).keys.firstAndOnly.or(throw: "Could not decode operation type")
            operation = try Operation(rawValue: name).or(throw: "Unrecognised operation \(name)")
            let container = try decoder.container(keyedBy: Operation.self)
            let operands = try container.decode(Operands.self, forKey: operation)
            lhs = operands.lhs
            if let decodable = lhs.any as? any Decodable {
                rhs = try AnyJSON(decodable.decode(operands.rhs.any, using: BlockchainNamespaceDecoder()))
            } else {
                rhs = operands.rhs
            }
        }
    }
}

extension Decodable {

    func decode(_ any: Any, using decoder: AnyDecoderProtocol) throws -> Any {
        try decoder.decode(Self.self, from: any)
    }
}

extension Compute.Comparison {

    func compute() throws -> Any? {
        switch operation {
        case .equal: return lhs == rhs
        case .match: return try rhs.decode(String.self).regex().hasMatch(in: lhs.decode(String.self))
        default:
            let result: Bool?
            guard let comparable = lhs.any as? any Comparable else { throw "Cannot compare \(lhs)" }
            switch operation {
            case .equal, .match: fatalError("impossible")
            case .greater, .less: result = comparable.compare(rhs.any, by: operation == .greater ? .greaterThan : .lessThan)
            case .greater_or_equal, .less_or_equal: result = comparable.compare(rhs.any, by: operation == .greater_or_equal ? .greaterThanOrEqual : .lessThanOrEqual)
            }
            return try result.or(throw: "Cannot compare \(lhs) \(type(of: lhs.any)) and \(rhs) \(type(of: rhs.any))".error())
        }
    }
}

extension Compute.Comparison: CustomStringConvertible {
    public var description: String { "Comparison(\(lhs) \(operation) \(rhs))" }
}

extension Compute.Comparison.Operation: CustomStringConvertible {
    public var description: String { string }
}

extension NSNumber: Comparable {
    public static func < (lhs: NSNumber, rhs: NSNumber) -> Bool { lhs.doubleValue < rhs.doubleValue }
}

enum ComparableComparison {
    case lessThan, lessThanOrEqual, greaterThan, greaterThanOrEqual
}
extension Comparable {

    func compare(_ other: Any, by comparison: ComparableComparison) -> Bool? {
        guard let other = other as? Self else { return nil }
        switch comparison {
        case .lessThan: return self < other
        case .lessThanOrEqual: return self <= other
        case .greaterThan: return self > other
        case .greaterThanOrEqual: return self >= other
        }
    }
}

extension String {

    func regex(_ options: NSRegularExpression.Options...) throws -> NSRegularExpression {
        try NSRegularExpression(pattern: self, options: NSRegularExpression.Options(options))
    }
}

extension NSRegularExpression {

    func hasMatch(in string: String) -> Bool {
        rangeOfFirstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)).location != NSNotFound
    }
}
