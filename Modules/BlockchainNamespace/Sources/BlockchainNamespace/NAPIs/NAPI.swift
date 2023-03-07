import Extensions
import OptionalSubscripts

public enum NAPI {}

extension NAPI {

    public actor Store {

        weak var app: AppProtocol?
        var data: Optional.Store = .init()
        var roots: [L_blockchain_namespace_napi: Root] = [:]

        init(_ app: AppProtocol) {
            self.app = app
        }

        func root(intent: Intent) throws -> Root {
            if let root = roots[intent.napi] { return root }
            let root = try NAPI.Root(intent.napi, store: self, context: intent.ref.context)
            roots[intent.napi] = root
            return root
        }

        nonisolated func publisher(for ref: Tag.Reference) -> AnyPublisher<FetchResult, Never> {
            do {
                let intent = try NAPI.Intent(ref)
                return intent.subject.handleEvents(
                    receiveSubscription: { _ in
                        Task { [weak self] in
                            guard let self else { return }
                            do {
                                try await self.root(intent: intent).handle(intent: intent)
                            } catch {
                                intent.subject.send(FetchResult(catching: { throw error }, ref.metadata(.napi)))
                            }
                        }
                    }
                ).eraseToAnyPublisher()
            } catch {
                return .just(.error(.other("Unable to form NAPI subscription because: \(error)"), ref.metadata(.napi)))
            }
        }
    }
}

extension NAPI {

    public actor Intent {

        typealias Domain = Tag.Reference

        fileprivate(set) static var subscriptions: [Domain: [UUID: AnyCancellable]] = [:]
        public var id: UUID

        public let napi: L_blockchain_namespace_napi
        public let ref: Tag.Reference

        let subject: PassthroughSubject<FetchResult, Never> = .init()

        public init(_ ref: Tag.Reference) throws {
            self.napi = try ref.tag.NAPI.or(throw: "No NAPI ancestor in \(ref)")
            self.ref = ref
            self.id = UUID()
        }

        func handle(_ error: Error) {
            subject.send(FetchResult(catching: { throw error }, ref.metadata(.napi)))
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

        init(_ id: L_blockchain_namespace_napi, store: Store, context: Tag.Context = [:]) throws {
            self.store = store
            self.id = id
            self.ref = try id.napi.collectionKey(to: context)
        }

        func subscribe() {
            guard subscription.isNil || subscription!.isCancelled else { return }
            subscription = Task {
                guard let app = await store?.app else { return }
                for await value in app.local.publisher(for: ref, app: app).decode([String: CodableVoid].self).stream() {
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
                        let domain = try domain(for: intent).or(throw: "No domain found for path \(ref) in napi \(id)")
                        try await domain.handle(intent: intent)
                    } catch {
                        await intent.handle(error)
                        self.intents.append(intent)
                    }
                }

            case .error(let error):
                for intent in intents {
                    await intent.handle(error)
                }
            }
        }

        func domain(for intent: Intent) -> Domain? {
            domains.sorted(
                by: { lhs, rhs in
                    (try? intent.ref.tag.distance(to: lhs.key) < intent.ref.tag.distance(to: rhs.key)) ?? false
                }
            )
            .first(
                where: { tag, _ in
                    tag.is(intent.ref.tag) || tag.isAncestor(of: intent.ref.tag)
                }
            )?.value
        }
    }
}

extension NAPI {

    public actor Domain {

        fileprivate weak var root: Root?

        let id: Tag
        let napi: L_blockchain_namespace_napi

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
        }
    }
}

extension NAPI {

    public actor Map {

        private weak var domain: Domain?
        private var scheduler: AnySchedulerOf<DispatchQueue> = .main.eraseToAnyScheduler()

        let src: Tag.Reference
        let dst: Tag.Reference

        private(set) var intents: [Intent] = []
        private var policy: NAPI.Instance.Policy?

        private var subscription: Task<Void, Never>?
        private var isSynchronized: Bool = false

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
                    if let stream = instance.value?.data.value as? (Tag.Reference) -> AsyncStream<AnyJSON> {
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

        func reset() {
            subscription = task()
        }

        func on(_ result: FetchResult.Value<NAPI.Instance>) async {
            switch result {
            case .value(let instance, _):
                isSynchronized = true
                do {
                    try await domain?.root?.store?.data.set(dst.route(app: domain?.root?.store?.app), to: instance.data.any)
                    policy = instance.policy
                    await fulfill()
                } catch {
                    await domain?.root?.store?.app?.post(error: error)
                }
            case .error(let error, _):
                await domain?.root?.store?.app?.post(error: error)
            }
        }

        func handle(intent: Intent) async {
            intents.append(intent)
            await fulfill()
        }

        func fulfill() async {
            guard let domain, let data = await domain.root?.store?.data else { return }
            guard isSynchronized else { return }
            defer { intents.removeAll(keepingCapacity: true) }
            for intent in intents {
                var publisher = await data.publisher(for: intent.ref, app: domain.root?.store?.app)
                if let debounce = policy?.debounce?.duration {
                    publisher = publisher.debounce(
                        for: .milliseconds(debounce),
                        scheduler: scheduler
                    ).eraseToAnyPublisher()
                }
                if let throttle = policy?.throttle {
                    publisher = publisher.throttle(
                        for: .milliseconds(throttle.duration),
                        scheduler: scheduler,
                        latest: throttle.latest ?? true
                    ).eraseToAnyPublisher()
                }
                await NAPI.Intent.subscriptions[src, default: [:]][intent.id] = publisher
                    .handleEvents(receiveOutput: intent.subject.send)
                    .subscribe()
            }
        }
    }
}

extension NAPI {

    public struct Instance: Decodable, Equatable {

        public struct Policy: Decodable, Equatable {

            public struct Debounce: Decodable, Equatable {
                public init(duration: Int) {
                    self.duration = duration
                }

                public let duration: Int
            }

            public struct Throttle: Decodable, Equatable {
                public init(duration: Int, latest: Bool?) {
                    self.duration = duration
                    self.latest = latest
                }

                public let duration: Int
                public let latest: Bool?
            }

            public init(
                attempts: Int? = nil,
                debounce: NAPI.Instance.Policy.Debounce? = nil,
                throttle: NAPI.Instance.Policy.Throttle? = nil
            ) {
                self.attempts = attempts
                self.debounce = debounce
                self.throttle = throttle
            }

            public let attempts: Int?
            public let debounce: Debounce?
            public let throttle: Throttle?
        }

        public let data: AnyJSON
        public let policy: Policy?

        public init(data: AnyJSON, policy: Policy? = nil) {
            self.data = data
            self.policy = policy
        }
    }
}
