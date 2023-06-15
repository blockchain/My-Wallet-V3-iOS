import Extensions

extension AppProtocol {

    public func binding(
        _ tempo: Bindings.Tempo = .sync,
        to context: Tag.Context = [:],
        managing updateManager: ((Bindings.Update) -> Void)? = nil
    ) -> Bindings {
        Bindings(app: self, tempo: tempo, context: context, handle: updateManager)
    }

    public func binding<Object: AnyObject>(
        _ object: Object,
        _ tempo: Bindings.Tempo = .sync,
        to context: Tag.Context = [:],
        managing updateManager: ((Object) -> (Bindings.Update) -> Void)? = nil
    ) -> Bindings.ToObject<Object> {
        Bindings(
            app: self,
            tempo: tempo,
            context: context,
            handle: { [weak object] update in
                guard let object else { return }
                updateManager?(object)(update)
            }
        )
        .object(object)
    }

    public func computed<Property: Decodable & Equatable>(
        _ event: Tag.Event,
        as type: Property.Type = Property.self,
        in context: Tag.Context = [:]
    ) -> AsyncStream<FetchResult.Value<Property>> {
        computed(event, as: type, in: context).stream()
    }

    @_disfavoredOverload
    public func computed<Property: Decodable & Equatable>(
        _ event: Tag.Event,
        as type: Property.Type = Property.self,
        in context: Tag.Context = [:]
    ) -> AnyPublisher<FetchResult.Value<Property>, Never> {
        publisher(for: event).computed(in: self, context: context).decode(Property.self)
    }
}

private enum ComputePublisherState {
    case idle, fetched(FetchResult)
    var fetchResult: FetchResult? {
        if case let .fetched(fetchResult) = self { return fetchResult }
        return nil
    }
}

extension Publisher where Output == FetchResult {

    func computed(in app: AppProtocol, context: Tag.Context = [:]) -> AnyPublisher<FetchResult, Failure> {
        flatMapLatest { output in
            ComputeFetchResultPublisher(app: app, context: context, input: output)
        }
        .eraseToAnyPublisher()
    }
}

private final class ComputeFetchResultPublisher<Failure: Error>: Publisher {

    typealias Output = FetchResult

    let app: AppProtocol
    let context: Tag.Context
    let input: FetchResult

    init(app: AppProtocol, context: Tag.Context, input: FetchResult) {
        self.app = app
        self.context = context
        self.input = input
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: Subscription(app: app, context: context, input: input, subscriber: subscriber))
    }

    final class Subscription<S: Subscriber>: Cancellable, Combine.Subscription where S.Input == Output, S.Failure == Failure {

        let app: AppProtocol
        let context: Tag.Context

        private let lock = UnfairLock()
        private var _unsafeHandler: Compute.HandlerProtocol?
        private var handler: Compute.HandlerProtocol? {
            _read {
                lock.lock(); defer { lock.unlock() }
                yield _unsafeHandler
            }
            _modify {
                lock.lock(); defer { lock.unlock() }
                yield &_unsafeHandler
            }
        }

        let input: FetchResult
        let subscriber: S

        init(app: AppProtocol, context: Tag.Context, input: FetchResult, subscriber: S) {
            self.app = app
            self.context = context
            self.input = input
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            guard handler.isNil else { return }
            handler = Compute.Handler(
                app: app,
                context: context,
                result: input,
                subscribed: true,
                type: AnyJSON.self,
                handle: { [subscriber] result in _ = subscriber.receive(result.any()) }
            )
        }

        func cancel() {
            handler = nil
        }
    }
}
