@_exported import AsyncAlgorithms

extension AsyncStream {

    public init<S: AsyncSequence & Sendable>(
        _ sequence: S,
        bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded
    ) where S.Element == Element {
        self.init(bufferingPolicy: limit) { (continuation: Continuation) in
            let task = Task {
                do {
                    for try await element in sequence {
                        continuation.yield(element)
                    }
                } catch {}
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            } as @Sendable (Continuation.Termination) -> Void
        }
    }

    public init(
        _ elementType: Element.Type = Element.self,
        priority: TaskPriority? = nil,
        bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded,
        _ build: @escaping (Continuation) async -> Void
    ) {
        self.init(Element.self, bufferingPolicy: limit) { continuation in
            let task = Task(priority: priority) {
                await build(continuation)
            }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }

    public static var never: Self {
        Self { _ in }
    }

    public static var finished: Self {
        Self { $0.finish() }
    }

    public static func just(_ element: Element) -> Self {
        Self { continuation in
            continuation.yield(element)
            continuation.finish()
        }
    }
}

extension Task where Failure == Never {

    public static func never() async throws -> Success {
        for await element in AsyncStream<Success>.never {
            return element
        }
        throw _Concurrency.CancellationError()
    }
}

extension Task where Success == Never, Failure == Never {

    public static func never() async throws {
        for await _ in AsyncStream<Never>.never {}
        throw _Concurrency.CancellationError()
    }
}

extension Task where Success == Failure, Failure == Never {
    @inlinable public static func megaYield(count: Int = 10) async {
        for _ in 1...count {
            await Task<Void, Never>.detached(priority: .background) { await Task.yield() }.value
        }
    }
}

extension AsyncStream {

    public static func streamWithContinuation(
        of elementType: Element.Type = Element.self,
        bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded
    ) -> (stream: Self, continuation: Continuation) {
        var continuation: Continuation!
        return (
            stream: Self(elementType, bufferingPolicy: limit) { __ in continuation = __ },
            continuation: continuation
        )
    }
}
