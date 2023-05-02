import Extensions
import OptionalSubscripts

public enum NAPI {}

extension NAPI {

    public actor Store {

        weak var app: AppProtocol?
        var scheduler: AnySchedulerOf<DispatchQueue> = .main.eraseToAnyScheduler()
        var data: Optional.Store = .init()
        var roots: [L_blockchain_namespace_napi: Root] = [:]

        init(_ app: AppProtocol) {
            self.app = app
        }

        func set(scheduler: AnySchedulerOf<DispatchQueue>) {
            self.scheduler = scheduler
        }

        func root(intent: Intent) -> Root {
            if let root = roots[intent.napi] { return root }
            let root = NAPI.Root(intent.napi, store: self, root: intent.root)
            roots[intent.napi] = root
            return root
        }

        nonisolated func publisher(for ref: Tag.Reference) -> AnyPublisher<FetchResult, Never> {
            do {
                let intent = try NAPI.Intent(ref)
                Task { await root(intent: intent).handle(intent: intent) }
                return intent.isFulfilled
                    .task { await data.publisher(for: ref, app: app) }
                    .switchToLatest()
                    .merge(with: intent.errors)
                    .handleEvents(
                        receiveSubscription: { _ in intent.increment() },
                        receiveCompletion: { _ in intent.decrement() },
                        receiveCancel: { intent.decrement() }
                    )
                    .eraseToAnyPublisher()
            } catch {
                return .just(FetchResult(error, metadata: ref.metadata(.napi)))
            }
        }
    }
}

extension NAPI {

    public class Intent {

        public var id: UUID
        public let napi: L_blockchain_namespace_napi
        public let root: Tag.Reference
        public let ref: Tag.Reference

        private let _isFulfilled: CurrentValueSubject<Bool, Never> = .init(false)
        var isFulfilled: AnyPublisher<Void, Never> {
            _isFulfilled.first(where: \.self).mapToVoid().eraseToAnyPublisher()
        }

        let errors: PassthroughSubject<FetchResult, Never> = .init()

        public init(_ ref: Tag.Reference) throws {
            self.id = UUID()
            self.napi = try ref.tag.NAPI.or(throw: "No NAPI ancestor in \(ref)")
            self.root = try napi.napi.collectionKey(to: ref.context)
            self.ref = ref
        }

        func fulfill() {
            _isFulfilled.send(true)
        }

        func handle(_ error: Error) {
            errors.send(FetchResult(error, metadata: ref.metadata(.napi)))
        }

        var count = ValueStore(0)

        func increment() {
            Task {
                let i = await count.value
                await count.set(to: i + 1)
            }
        }

        func decrement() {
            Task.detached(priority: .low) { [count] in
                await Task.yield()
                let i = await count.value
                precondition(i > 0)
                await count.set(to: i - 1)
            }
        }
    }
}

extension NAPI {

    public actor Root {

        enum State {
            case requesting
            case ready
            case error(Error)
        }

        weak var store: Store?

        let id: L_blockchain_namespace_napi
        let ref: Tag.Reference

        var domains: [Tag: Domain] = [:]
        var state: State = .requesting

        var intents: [Intent] = []
        var subscription: Task<Void, Never>?

        init(_ id: L_blockchain_namespace_napi, store: Store, root: Tag.Reference) {
            self.store = store
            self.id = id
            self.ref = root
        }

        func subscribe() {
            guard subscription.isNil || subscription!.isCancelled else { return }
            subscription = Task {
                guard let app = await store?.app else { return }
                for await value in await app.local.publisher(for: ref, app: app).decode([String: CodableVoid].self).stream() {
                    await on(value)
                }
            }
        }

        func on(_ result: FetchResult.Value<[String: CodableVoid]>) async {
            do {
                switch result {
                case .value(let domains, _):
                    self.domains = try domains.keys.map { try Tag(id: $0, in: ref.tag.language) }
                        .reduce(into: [:]) { a, e in a[e] = Domain(e, of: self) }
                    state = .ready
                    await fulfill()
                default: break
                }
            } catch {
                state = .error(error)
                await store?.app?.post(error: error)
            }
        }

        func handle(intent: Intent) async {
            subscribe()
            intents.append(intent)
            switch state {
            case .requesting: break
            case .ready, .error: await fulfill()
            }
        }

        func fulfill() async {
            switch state {
            case .requesting:
                return

            case .ready:
                let intents = intents
                self.intents.removeAll(keepingCapacity: true)
                for intent in intents {
                    do {
                        let domain = try await domain(for: intent).or(throw: "No domain found for path \(ref) in napi \(id)")
                        try await domain.handle(intent: intent)
                    } catch {
                        intent.handle(error)
                        self.intents.append(intent)
                    }
                }

            case .error(let error):
                for intent in intents {
                    intent.handle(error)
                }
            }
        }

        func domain(for intent: Intent) async -> Domain? {
            do {
                let domains = try domains
                    .filter { tag, _ in tag.is(intent.ref.tag) || tag.isAncestor(of: intent.ref.tag) }
                    .sorted(
                        by: { lhs, rhs in
                            try intent.ref.tag.distance(to: lhs.key) < intent.ref.tag.distance(to: rhs.key)
                        }
                    )

                guard let first = domains.first else { return nil }

                if domains.count > 1, first.key != intent.ref.tag {
                    print("❓ Multiple domains found to handle intent \(intent.ref), choosing \(first.key.id) out of [\(domains.map(\.key.id).joined(separator: ", "))]")
                }

                return first.value
            } catch {
                await store?.app?.post(error: error)
                return nil
            }
        }
    }
}

extension NAPI {

    public actor Domain {

        fileprivate weak var root: Root?

        let id: Tag
        let napi: L_blockchain_namespace_napi

        var counts: [UUID: Int] = [:]

        func count(of id: UUID, setTo value: Int) {
            counts[id] = value
        }

        var count: Int {
            counts.values.reduce(0, +)
        }

        var isEmpty: Bool { count == 0 }

        lazy var indices: Tag.Context = [napi.napi.id: id.id]

        private(set) var maps: [String: Map] = [:]

        init(_ tag: Tag, of root: Root) {
            self.id = tag
            self.root = root
            self.napi = root.id
        }

        func handle(intent: Intent) async throws {
            let ref = intent.ref
            let src = try await napi.napi[].ref(to: ref.indices.asContext() + indices, in: root?.store?.app).validated()
            let dst = try await id.ref(to: ref.indices.asContext(), in: root?.store?.app).validated()
            if let map = maps[dst.string] {
                await map.handle(intent: intent)
            } else {
                let map = await Map(from: src, to: dst, in: self)
                maps[dst.string] = map
                await map.handle(intent: intent)
            }
            Task {
                for await i in await intent.count.stream() {
                    count(of: intent.id, setTo: i)
                    if i == 0 { return }
                }
            }
        }
    }
}

extension NAPI {

    public actor Map {

        private weak var domain: Domain?

        let src: Tag.Reference
        let dst: Tag.Reference

        private(set) var intents: [Intent] = []

        private var subscription: Task<Void, Never>?
        private var isSynchronized: Bool = false, isDirty: Bool = false

        init(
            from src: Tag.Reference,
            to dst: Tag.Reference,
            in domain: Domain
        ) async {
            self.src = src
            self.dst = dst
            self.domain = domain
            self.subscription = task()
        }

        func task() -> Task<Void, Never> {
            Task { [domain, src] in
                guard let app = await domain?.root?.store?.app else { return }
                isSynchronized = false
                for await result in app.stream(src) {
                    let instance = result.decode(Instance.self)
                    if let fn = instance.value?.data.value as? (Tag.Reference) async -> AnyJSON {
                        await self.on(.value(.init(data: fn(dst), policy: instance.value?.policy), src.metadata(.napi)))
                    } else if let stream = instance.value?.data.value as? (Tag.Reference) -> AsyncStream<AnyJSON> {
                        for await value in stream(dst) {
                            await self.on(.value(.init(data: value, policy: instance.value?.policy), src.metadata(.napi)))
                        }
                    } else if let publisher = instance.value?.data.value as? (Tag.Reference) -> AnyPublisher<AnyJSON, Never> {
                        for await value in publisher(dst).stream() {
                            await self.on(.value(.init(data: value, policy: instance.value?.policy), src.metadata(.napi)))
                        }
                    } else {
                        await self.on(instance)
                    }
                }
            }
        }

        func reset() async {
            guard let domain else { return }
            isSynchronized = false
            if await domain.isEmpty {
                policy.subscription.on?.cancel()
                policy.subscription.after = nil
                isDirty = true
            } else {
                subscription = task()
            }
        }

        func on(_ result: FetchResult.Value<NAPI.Instance>) async {
            switch result {
            case .value(let instance, _):
                isSynchronized = true
                do {
                    try await domain?.root?.store?.data.merge(dst.route(app: domain?.root?.store?.app), with: instance.data.any)
                    await fulfill()
                    guard let it = instance.policy else { return }
                    await policy(it)
                } catch {
                    await domain?.root?.store?.app?.post(error: error)
                }
            case .error(let error, _):
                await domain?.root?.store?.app?.post(error: error)
            }
        }

        var policy = (
            subscription: (on: AnyCancellable?.none, after: UUID?.none), ()
        )

        func policy(_ policy: L_blockchain_namespace_napi_napi_policy.JSON) async {
            guard let domain else { return }
            if let tag = try? policy.invalidate.on([Tag.Reference].self) {
                self.policy.subscription.on = await domain.root?.store?.app?.on(tag) { [weak self] _ in await self?.reset() }
                    .subscribe()
            } else {
                self.policy.subscription.on = nil
            }
            if let duration: TimeInterval = policy.invalidate.after.duration, let scheduler = await domain.root?.store?.scheduler {
                let id = UUID()
                scheduler.schedule(after: scheduler.now.advanced(by: .seconds(duration))) { [weak self, id] in
                    Task { [weak self] in
                        guard await id == self?.policy.subscription.after else { return }
                        await self?.reset()
                    }
                }
                self.policy.subscription.after = id
            } else {
                self.policy.subscription.after = nil
            }
        }

        func handle(intent: Intent) async {
            intents.append(intent)
            if isDirty {
                isDirty = false
                subscription = task()
            }
            await fulfill()
        }

        func fulfill() async {
            guard isSynchronized else { return }
            let intents = intents
            self.intents.removeAll(keepingCapacity: true)
            for intent in intents {
                intent.fulfill()
            }
        }
    }
}

extension NAPI {

    public struct Instance: Decodable, Equatable {

        public let data: AnyJSON
        public let policy: L_blockchain_namespace_napi_napi_policy.JSON?

        public init(data: AnyJSON, policy: L_blockchain_namespace_napi_napi_policy.JSON? = nil) {
            self.data = data
            self.policy = policy
        }
    }
}

extension Optional<Any>.Store {

    func merge<Route>(_ route: Route, with value: Any?) where Route: Collection, Route.Index == Int, Route.Element == Location {
        switch (data[route], value) {
        case (let d1 as [String: Any], let d2 as [String: Any]):
            set(route, to: d1.deepMerging(d2, uniquingKeysWith: { $1 }))
        case _:
            set(route, to: value)
        }
    }
}
