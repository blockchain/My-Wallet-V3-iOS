public func combineLatest<C>(
    _ collection: C,
    bufferingPolicy limit: AsyncStream<[C.Element.Element]>.Continuation.BufferingPolicy = .unbounded
) -> AsyncStream<[C.Element.Element]> where C: Collection, C.Element: AsyncSequence {
    AsyncStream(bufferingPolicy: limit) { continuation in
        let stream = CombineLatestActor<C.Element.Element>(collection.count)
        continuation.onTermination = { @Sendable _ in
            Task { await stream.cancel() }
        }
        for (i, sequence) in collection.enumerated() {
            Task {
                for try await value in sequence {
                    if await stream.isCancelled {
                        throw CancellationError()
                    }
                    if let values = await stream.insert(value, at: i) {
                        continuation.yield(values)
                    }
                }
                if await stream.complete(i) {
                    continuation.finish()
                }
            }
        }
    }
}

private actor CombineLatestActor<Element> {

    var values: [Element?]
    var seen, completed: Set<Int>
    var isCancelled: Bool = false

    init(_ count: Int) {
        self.values = [Element?](repeating: nil, count: count)
        self.seen = .init(minimumCapacity: count)
        self.completed = .init(minimumCapacity: count)
    }

    @discardableResult
    func insert(_ value: Element, at index: Int) -> [Element]? {
        seen.insert(index)
        values[index] = value
        return seen.count == values.count ? values.compacted().array : nil
    }

    @discardableResult
    func complete(_ index: Int) -> Bool {
        completed.insert(index)
        return completed.count == values.count
    }

    func cancel() {
        isCancelled = true
    }
}
