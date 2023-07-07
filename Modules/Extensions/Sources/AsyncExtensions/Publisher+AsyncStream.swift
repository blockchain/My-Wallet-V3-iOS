#if canImport(Combine)
import Combine
#endif

#if canImport(Combine)
extension Publisher {

    @discardableResult
    public func await(file: String = #file, line: Int = #line) async throws -> Output {
        try await values.next(file: file, line: line)
    }
}

extension Publisher where Failure == Never {

    @discardableResult
    public func await() async throws -> Output {
        try await values.next()
    }
}
#endif
