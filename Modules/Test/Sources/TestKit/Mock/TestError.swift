// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A mock error.
public enum MockError: Error {

    /// Unknown error.
    case unknown

    // MARK: - Internal Properties

    var description: String {
        switch self {
        case .unknown:
            "unknown"
        }
    }
}

public struct TestError: Error {

    let message: String
    let function: String
    let file: String
    let line: Int

    public init(
        _ message: String = "",
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) {
        self.message = message
        (self.function, self.file, self.line) = (function, file, line)
    }
}

extension TestError: CustomStringConvertible {

    public var description: String {
        "\(message) ← \(function)\t\(file)\(line)"
    }
}
