#if canImport(Combine)
import Combine
#endif

#if canImport(Combine)
extension Publisher {

    public func stream(
        bufferingPolicy: AsyncThrowingStream<Output, Error>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncThrowingStream<Output, Error> {
        AsyncThrowingStream(bufferingPolicy: bufferingPolicy) { continuation in
            var cancellable: AnyCancellable?
            let onTermination = { cancellable?.cancel() }

            continuation.onTermination = { @Sendable _ in
                onTermination()
            }

            cancellable = sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        continuation.finish()
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                }, receiveValue: { value in
                    continuation.yield(value)
                }
            )
        }
    }

    @discardableResult
    public func await(file: String = #file, line: Int = #line) async throws -> Output {
        try await stream().next(file: file, line: line)
    }
}

extension Publisher where Failure == Never {

    public func stream(
        bufferingPolicy: AsyncStream<Output>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<Output> {
        AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
            var cancellable: AnyCancellable?
            let onTermination = { cancellable?.cancel() }

            continuation.onTermination = { @Sendable _ in
                onTermination()
            }

            cancellable = sink(
                receiveCompletion: { _ in
                    continuation.finish()
                }, receiveValue: { value in
                    continuation.yield(value)
                }
            )
        }
    }

    @discardableResult
    public func await() async throws -> Output {
        try await stream().next()
    }
}
#endif
