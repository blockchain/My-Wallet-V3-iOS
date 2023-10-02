import Extensions

extension Computer {
    public static let `default` = Computer(
        [
            "comparison": Compute.Comparison.self,
            "count": Compute.Count.self,
            "either": Compute.Either.self,
            "error": Compute.Error.self,
            "eval": Compute.Eval.self,
            "exists": Compute.Exists.self,
            "from": Compute.From.self,
            "item": Compute.Item.self,
            "language": Compute.Language.self,
            "not": Compute.Not.self,
            "map": Compute.Map.self,
            "this": Compute.This.self,
            "text": Compute.Text.self,
            "yes": Compute.Yes.self
        ]
    )
}

public struct Computer {
    public let functions: [String: Compute.Keyword]
    public init(_ keywords: [String: AnyReturnsKeyword.Type]) {
        self.functions = Dictionary(
            uniqueKeysWithValues: keywords.map { keyword, type in
                (keyword, .init(name: keyword, type: type))
            }
        )
    }

    public subscript(string: String) -> Compute.Keyword? { functions[string] }
}

public protocol AnyReturnsKeyword: Decodable {

    static func handler(
        for data: Any,
        defaultingTo defaultValue: Any?,
        context: Tag.Context,
        in app: AppProtocol,
        subscribed: Bool,
        handle: @escaping (FetchResult) -> Void
    ) -> Compute.HandlerProtocol?
}

public protocol AnyComputeKeyword: AnyReturnsKeyword {
    func compute() throws -> Any?
}

public protocol ReturnsKeyword: AnyReturnsKeyword, Equatable {}
public protocol ComputeKeyword: AnyComputeKeyword, Equatable {}

extension Compute {

    public struct Keyword {
        public let name: String
        public let type: AnyReturnsKeyword.Type
    }
}

extension Compute.Keyword: Equatable, CustomStringConvertible {
    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.name == rhs.name }
    public var computeType: AnyComputeKeyword.Type? { type as? AnyComputeKeyword.Type }
    public var isComputeKeyword: Bool { type is AnyComputeKeyword.Type }
    public var isNotComputeKeyword: Bool { !isComputeKeyword }
    public var description: String { name }
}

extension Compute.Keyword {

    public init?(returns data: [String: Any]?, computer: Computer = .default) {
        guard let data = data?[Compute.key.returns] as? [String: Any] else { return nil }
        guard let keyword = data.keys.firstAndOnly else { return nil }
        guard let function = computer[keyword] else { return nil }
        self = function
    }
}

extension Compute {

    @TaskLocal static var context = Compute.Context()

    @discardableResult
    static func withContext<R>(
        _ body: (inout Compute.Context) throws -> Void,
        operation: () async throws -> R,
        file: String = #fileID,
        line: UInt = #line
    ) async rethrows -> R {
        var scoped = Compute.context
        try body(&scoped)
        return try await Compute.$context.withValue(scoped, operation: operation, file: file, line: line)
    }

    @discardableResult
    static func withContext<R>(
        _ body: (inout Compute.Context) throws -> Void,
        operation: () throws -> R,
        file: String = #fileID,
        line: UInt = #line
    ) rethrows -> R {
        var scoped = Compute.context
        try body(&scoped)
        return try Compute.$context.withValue(scoped, operation: operation, file: file, line: line)
    }

    @propertyWrapper
    public struct Context: Equatable, Decodable {
        public enum Key { case element }
        public var data: [Key: AnyJSON] = [:]
        public subscript(key: Key) -> AnyJSON? { data[key] }
        public var wrappedValue: Self { Compute.context }
        public init(from decoder: Decoder) throws { self = Compute.context }
        public init() {}
    }
}

extension Decoder {
    var context: Compute.Context { Compute.context }
}

extension Compute.Context {

    public var element: AnyJSON? {
        get { data[.element] }
        set { data[.element] = newValue }
    }
}

extension Compute {

    public static func from(
        returns data: [String: Any],
        context: Tag.Context,
        in app: AppProtocol,
        using computer: Computer = .default,
        subscribed: Bool,
        handle: @escaping (FetchResult) -> Void
    ) -> Compute.HandlerProtocol? {
        do {
            guard let returns = data[Compute.key.returns] as? [String: Any] else { throw "Expected {returns}" }
            guard let key = returns.keys.firstAndOnly else { throw "Expected 1 keyword, but got \(returns.keys.count)" }
            guard let keyword = computer[key], let compute = returns[keyword.name] else { throw "Expected {returns} keyword, but got \(returns.keys.first!)" }
            return keyword.type.handler(
                for: compute,
                defaultingTo: data[Compute.key.default],
                context: context,
                in: app,
                subscribed: subscribed,
                handle: handle
            )
        } catch {
            if let data = data[Compute.key.default] {
                handle(.value(data, metadata()))
            } else {
                handle(.error(error, metadata()))
            }
            return nil
        }
    }
}

extension AnyReturnsKeyword {

    static func from(_ data: Any) throws -> Self {
        try ComputeDecoder().decode(Self.self, from: data)
    }
}

extension ComputeKeyword {

    public static func handler(
        for data: Any,
        defaultingTo defaultValue: Any?,
        context: Tag.Context,
        in app: AppProtocol,
        subscribed: Bool,
        handle: @escaping (FetchResult) -> Void
    ) -> Compute.HandlerProtocol? {
        Compute.Handler(
            app: app,
            context: context,
            result: .value(data, Compute.metadata()),
            subscribed: subscribed,
            type: Self.self
        ) { result in
            do {
                let result = try Self.from(result.get()).compute()
                handle(.value(result as Any, Compute.metadata()))
            } catch {
                if let data = defaultValue {
                    handle(.value(data, Compute.metadata()))
                } else {
                    handle(.error(error, Compute.metadata()))
                }
            }
        }
    }
}
