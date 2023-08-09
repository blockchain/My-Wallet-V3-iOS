#if canImport(Combine)
import Combine

extension Publisher {

    @discardableResult
    public func await(file: String = #file, line: Int = #line) async throws -> Output {
        try await values.next(file: file, line: line)
    }
}
#endif
