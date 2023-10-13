import SwiftUI

public enum AsyncState<Value, Failure: Error> {

    case idle
    case loading
    case success(Value)
    case failure(Failure)

    @inlinable public var isIdle: Bool {
        if case .idle = self { return true } else { return false }
    }

    @inlinable public var isLoading: Bool {
        if case .loading = self { return true } else { return false }
    }

    @inlinable public var isSuccess: Bool {
        if case .success = self { return true } else { return false }
    }

    @inlinable public var isFailure: Bool {
        if case .failure = self { return true } else { return false }
    }
}

extension AsyncState where Value == Void {
    @inlinable public static var success: Self { .success(()) }
}

extension AsyncState: Equatable {

    public static func == (lhs: AsyncState<Value, Failure>, rhs: AsyncState<Value, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case let (.success(s1), .success(s2)): return isEqual(s1, s2)
        case let (.failure(e1), .failure(e2)): return String(describing: e1) == String(describing: e2)
        default: return false
        }
    }
}

public protocol LoadableObject<Output, Failure>: ObservableObject {
    associatedtype Output
    associatedtype Failure: Error
    var state: AsyncState<Output, Failure> { get }
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
        case .failure(let error):
            errorView(error)
        case .success(let output):
            content(output)
        }
    }
}

public class ConcurrencyLoadableObject<Success>: LoadableObject {

    @Published public private(set) var state = AsyncState<Success, Error>.idle

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
                    state = .success(value)
                }
            } catch {
                withAnimation(animation) {
                    state = .failure(error)
                }
            }
        }
    }
}

#if canImport(Combine)
import Combine

public class PublishedObject<Wrapped: Publisher, S: Scheduler>: LoadableObject {

    @Published public private(set) var state = AsyncState<Wrapped.Output, Wrapped.Failure>.idle

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
            .map(AsyncState.success)
            .catch { error in
                Just(AsyncState.failure(error))
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
