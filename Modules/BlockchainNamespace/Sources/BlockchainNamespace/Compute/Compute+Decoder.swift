import Extensions

open class ReturnsDecoder: ComputeDecoder {

    enum Result<T> {
        case ready(T), computes(Set<Compute.JSON>)
    }

    var isComputing = false
    var isNotComputing: Bool { !isComputing }
    var isDecoding = false
    var isEncodingErrors: Bool = false

    private(set) var computes: Set<Compute.JSON> = []

    open override func convert<T>(_ any: Any, to: T.Type) throws -> Any? {
        do {
            if isNotComputing, let error = any as? Error { throw error }
            if isDecoding, let returns = try convertReturns(any, as: T.self) { return returns }
            return try super.convert(any, to: T.self)
        } catch where isEncodingErrors && T.self == AnyJSON.self {
            return AnyJSON(error)
        }
    }

    private func convertReturns<T>(_ any: Any, as: T.Type) throws -> Any? {
        guard let dictionary = any as? [String: Any], dictionary[Compute.key.returns].isNotNil else { return nil }
        guard let keyword = Compute.Keyword(returns: dictionary) else { return dictionary[Compute.key.default] }
        guard keyword.isNotComputeKeyword else { return nil }
        let empty = try empty(T.self, at: codingPath)
        computes.insert(Compute.JSON(codingPath: codingPath, returns: dictionary, empty: empty))
        return empty
    }

    func decodeWithComputes<T: Decodable>(_: T.Type = T.self, from any: Any) throws -> Result<T> {
        let old = (isDecoding, computes)
        defer { (isDecoding, computes) = old }
        (isDecoding, computes) = (true, [])
        do {
            let value = try decode(T.self, from: any)
            return computes.isEmpty ? .ready(value) : .computes(computes)
        } catch where computes.isNotEmpty {
            return .computes(computes)
        }
    }
}

open class ComputeDecoder: BlockchainNamespaceDecoder {

    open override func convert<T>(_ any: Any, to: T.Type) throws -> Any? {
        if let returns = try compute(any, as: T.self) { return returns }
        return try super.convert(any, to: T.self)
    }

    fileprivate func compute<T>(_ any: Any, as: T.Type) throws -> Any? {
        guard let dictionary = any as? [String: Any], dictionary[Compute.key.returns].isNotNil else { return nil }
        guard let returns = dictionary[Compute.key.returns] as? [String: Any] else { throw AnyJSON.Error("Expected {returns}") }
        codingPath.append(AnyCodingKey(Compute.key.returns))
        defer { codingPath.removeLast() }
        guard let key = returns.keys.firstAndOnly, let function = returns[key] else { throw AnyJSON.Error("Expected 1 keyword, but got \(returns.keys.count)") }
        codingPath.append(AnyCodingKey(key))
        defer { codingPath.removeLast() }
        guard let keyword = Compute.Keyword(returns: dictionary) else { throw AnyJSON.Error("Expected {returns} keyword, but got \(returns.keys.first!)") }
        if let computeType = keyword.computeType {
            do {
                let computer = try decode(computeType, from: function)
                let result = try computer.compute().throwIfError()
                guard let type = T.self as? any Decodable.Type else { return result }
                return try decode(type, from: result as Any)
            } catch {
                guard let value = dictionary[Compute.key.default] else { throw error }
                codingPath.append(AnyCodingKey(Compute.key.default))
                defer { codingPath.removeLast() }
                guard let type = T.self as? any Decodable.Type else { return value }
                return try decode(type, from: value)
            }
        } else {
            return nil
        }
    }

    fileprivate func empty<T>(_ type: T.Type = T.self, at codingPath: [CodingKey]) throws -> Any {
        if let empty = try (T.self as? Decodable.Type)?.empty() { return empty }
        throw AnyJSON.Error(
            """
            Value at coding path '\(codingPath.string)' should be computed \
            but the target type \(T.self) is not decodable
            """
        )
    }
}
