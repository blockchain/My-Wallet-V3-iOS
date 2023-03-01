import SwiftUI

public enum LoadingState<Value, Failure: Error> {
    case idle
    case loading
    case failed(Failure)
    case loaded(Value)
}

public protocol LoadableObject<Output, Failure>: ObservableObject {
    associatedtype Output
    associatedtype Failure: Error
    var state: LoadingState<Output, Failure> { get }
    func load()
}

public struct AsyncContentView<
    Source: LoadableObject,
    LoadingView: View,
    ErrorView: View,
    Content: View
>: View {

    @StateObject var source: Source
    var loadingView: LoadingView
    var errorView: (Source.Failure) -> ErrorView
    var content: @MainActor (Source.Output) -> Content

    public init(
        source: Source,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder errorView: @escaping (Source.Failure) -> ErrorView,
        @ViewBuilder content: @MainActor @escaping (Source.Output) -> Content
    ) {
        _source = .init(wrappedValue: source)
        self.loadingView = loadingView
        self.errorView = errorView
        self.content = content
    }

    public var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            loadingView
        case .failed(let error):
            errorView(error)
        case .loaded(let output):
            content(output)
        }
    }
}

public class ConcurrencyLoadableObject<Success>: LoadableObject {

    @Published public private(set) var state = LoadingState<Success, Error>.idle

    private var create: () -> Task<Success, Error>
    private var subscription: Task<Void, Never>?

    private let animation: Animation?

    public init(create: @escaping () -> Task<Success, Error>, animation: Animation? = .linear) {
        self.create = create
        self.animation = animation
    }

    public func load() {
        subscription = Task { @MainActor in
            state = .loading
            do {
                let value = try await create().value
                withAnimation(animation) {
                    state = .loaded(value)
                }
            } catch {
                withAnimation(animation) {
                    state = .failed(error)
                }
            }
        }
    }
}

#if canImport(Combine)
import Combine

public class PublishedObject<Wrapped: Publisher, S: Scheduler>: LoadableObject {

    @Published public private(set) var state = LoadingState<Wrapped.Output, Wrapped.Failure>.idle

    private let publisher: Wrapped
    private var subscription: AnyCancellable?
    private var scheduler: S
    private let animation: Animation?

    public init(publisher: Wrapped, scheduler: S = DispatchQueue.main, animation: Animation? = .linear) {
        self.publisher = publisher
        self.scheduler = scheduler
        self.animation = animation
    }

    public func load() {
        state = .loading
        subscription = publisher
            .map(LoadingState.loaded)
            .catch { error in
                Just(LoadingState.failed(error))
            }
            .receive(on: scheduler.animation(animation))
            .sink { [weak self] state in
                self?.state = state
            }
    }
}

extension AsyncContentView {

    public init<P: Publisher>(
        source: P,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder errorView: @escaping (P.Failure) -> ErrorView,
        @ViewBuilder content: @MainActor @escaping (P.Output) -> Content
    ) where Source == PublishedObject<P, DispatchQueue> {
        self.init(
            source: PublishedObject(publisher: source),
            loadingView: loadingView,
            errorView: errorView,
            content: content
        )
    }

    public init<T>(
        source: @escaping () -> Task<T, Error>,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder errorView: @escaping (Error) -> ErrorView,
        @ViewBuilder content: @MainActor @escaping (T) -> Content
    ) where Source == ConcurrencyLoadableObject<T> {
        self.init(
            source: ConcurrencyLoadableObject(create: source),
            loadingView: loadingView,
            errorView: errorView,
            content: content
        )
    }

    public init<T>(
        source: @escaping () async throws -> T,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder errorView: @escaping (Error) -> ErrorView,
        @ViewBuilder content: @MainActor @escaping (T) -> Content
    ) where Source == ConcurrencyLoadableObject<T> {
        self.init(
            source: ConcurrencyLoadableObject {
                Task { try await source() }
            },
            loadingView: loadingView,
            errorView: errorView,
            content: content
        )
    }
}
#endif

extension AsyncContentView where Source.Failure == Never, ErrorView == EmptyView {

    public init(
        source: Source,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder content: @MainActor @escaping (Source.Output) -> Content
    ) {
        self.init(
            source: source,
            loadingView: loadingView,
            errorView: absurd,
            content: content
        )
    }

    public init<P>(
        source: P,
        loadingView: LoadingView = ProgressView(),
        @ViewBuilder content: @MainActor @escaping (Source.Output) -> Content
    ) where Source == PublishedObject<P, DispatchQueue> {
        self.init(
            source: source,
            loadingView: loadingView,
            errorView: absurd,
            content: content
        )
    }
}

extension EmptyView {
    public init(ignored: some Any) {
        self = EmptyView()
    }
}
