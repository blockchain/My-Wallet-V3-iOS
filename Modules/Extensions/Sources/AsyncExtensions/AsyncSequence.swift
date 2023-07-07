// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import Foundation

public enum AsyncSequenceNextError: Error, LocalizedError {
    case terminated(file: String, line: Int)
    case timeout(file: String, line: Int)
}

extension AsyncSequenceNextError {

    public var errorDescription: String? {
        switch self {
        case .terminated(let file, let line):
            return "Terminated without returning an value. \(file):\(line)"
        case .timeout(let file, let line):
            return "Times out waiting for a value. \(file):\(line)"
        }
    }
}

extension AsyncSequence {

    public func next(file: String = #fileID, line: Int = #line) async throws -> Element {
        for try await o in self {
            return o
        }
        throw AsyncSequenceNextError.terminated(file: file, line: line)
    }

    public func next<S: Scheduler>(timeout: S.SchedulerTimeType.Stride, scheduler: S, file: String = #fileID, line: Int = #line) async throws -> Element {
        try await withThrowingTaskGroup(of: Element.self) { group in
            group.addTask {
                for try await o in self { return o }
                throw AsyncSequenceNextError.terminated(file: file, line: line)
            }
            group.addTask {
                try await scheduler.sleep(for: timeout)
                throw AsyncSequenceNextError.timeout(file: file, line: line)
            }
            return try await group.next()
        }
    }
}
