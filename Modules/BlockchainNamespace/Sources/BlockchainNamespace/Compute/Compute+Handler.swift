import Extensions

extension Compute {
    public typealias Handler<Property: Decodable & Equatable> = ComputeHandler<Property>
    public typealias HandlerProtocol = ComputeHandlerProtocol
}

public protocol ComputeHandlerProtocol: AnyObject {
    var result: FetchResult { get }
    var recursiveBindings: Set<Bindings.Binding> { get }
}

extension Compute.HandlerProtocol {
    typealias My = Self
}

public class ComputeHandler<Property: Decodable & Equatable>: Compute.HandlerProtocol {

    weak var app: AppProtocol?

    let context: Tag.Context
    public let result: FetchResult
    let isSubscribed: Bool
    let handle: (FetchResult.Value<Property>) -> Void

    var state = State()

    public var recursiveBindings: Set<Bindings.Binding> {
        state.bindings.flatMap(\.bindings).set
    }

    private(set) var oldValue: Property?
    var isInTransaction: Bool { app?.isInTransaction ?? false }

    public init(
        app: AppProtocol?,
        context: Tag.Context,
        result: FetchResult,
        subscribed: Bool,
        type: Property.Type,
        handle: @escaping (FetchResult.Value<Property>) -> Void
    ) {
        self.app = app
        self.context = context
        self.result = result
        self.isSubscribed = subscribed
        self.handle = handle
        do {
            try decode(result.get())
        } catch {
            handle(.error(error, result.metadata))
        }
    }

    func decode(_ any: Any) throws {
        let decoder = ReturnsDecoder()
        decoder.isComputing = result.metadata.source == .compute
        switch try decoder.decodeWithComputes(Property.self, from: any) {
        case .ready(let value):
            guard decoder.isComputing else { return handle(.value(value, result.metadata)) }
            if isInTransaction || value == oldValue { return }
            oldValue = value
            handle(.value(value, result.metadata))
        case .computes(let computes):
            try decode(with: computes)
        }
    }

    func decode(with computes: Set<Compute.JSON>) throws {
        guard state.depth < 20 else { throw AnyJSON.Error("Reached compute depth of \(state.depth) with result \(result). Check for infinite recursion.") }
        guard let app else { return }
        let bindings = Bindings(app: app, context: context, handle: on(update:))
        state.append(bindings, by: binding, with: computes)
        guard bindings.isNotEmpty else { return update(at: state.depth) }
        bindings.request()
    }

    func on(update u: Bindings.Update) {
        guard let depth = u.depth else { return }
        update(at: depth)
    }

    func update(at depth: Int) {
        var depth = depth
        do {
            guard try state.bindings.at(depth).or(throw: AnyJSON.Error("No bindings found at depth \(depth)")).isSynchronized else { return }
            var result = try state.raise(to: depth) ?? result.get()
            for next in 0...depth {
                depth = next
                let bindings = try state.bindings.at(depth).or(throw: AnyJSON.Error("No bindings found at depth \(depth)")).bindings
                for binding in bindings {
                    guard let error = binding.result.error?.any else { continue }
                    try state.computes[depth][binding.compute.or(throw: AnyJSON.Error("Missing compute in binding"))] = error
                }
                result = apply(state.computes[depth], to: result)
                state.store(result, at: depth)
            }
            try decode(result)
        } catch {
            state.raise(to: depth)
            handle(.error(error, result.metadata))
        }
    }

    func binding(to json: Compute.JSON, at depth: Int, bindings: Bindings) throws {
        bindings.insert(Bindings.Binding(bindings, compute: json, subscribed: isSubscribed, to: self, \.state[depth, json]))
    }

    func apply(_ computes: [Compute.JSON: Any], to result: Any?) -> Any {
        var result = result
        for (compute, value) in computes {
            result[compute.codingPath] = value
        }
        return result as Any
    }
}

extension Compute.Handler {

    class State {

        var depth: Int { bindings.count - 1 }

        private(set) var result: [Any] = []
        private(set) var bindings: [Bindings] = []
        fileprivate(set) var computes: [[Compute.JSON: Any]] = []

        init() {}

        subscript(depth: Int, i: Compute.JSON) -> Any {
            get { computes.at(depth)?[i] ?? AnyJSON.Error("Index not found at depth \(depth) for data \(i)") }
            set {
                guard computes.indices ~= depth else { return }
                computes[depth][i] = newValue
            }
        }

        func append(
            _ b: Bindings,
            by binding: (Compute.JSON, Int, Bindings) throws -> Void,
            with c: Set<Compute.JSON>
        ) {
            computes.append([:])
            bindings.append(b)
            b.depth = depth
            for compute in c {
                self[depth, compute] = compute.empty
                do {
                    try binding(compute, depth, b)
                } catch {
                    self[depth, compute] = error
                }
            }
        }

        @discardableResult
        func raise(to depth: Int) -> Any? {
            result = result.prefix(upTo: depth).array
            bindings = bindings.prefix(through: depth).array
            computes = computes.prefix(through: depth).array
            return result.at(depth - 1)
        }

        func store(_ any: Any, at depth: Int) {
            if result.indices ~= depth {
                result[depth] = any
            } else {
                result.append(any)
            }
        }
    }
}
