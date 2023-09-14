// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Class in charge of logging debug/info/warning/error messages to a `LogDestination`.
@objc public class Logger: NSObject {

    public enum Verbosity {
        case very
        case some
        case none
    }

    var destinations = [LogDestination]()

    private lazy var timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    public static let shared: Logger = {
        let logger = Logger()
        #if DEBUG
        logger.destinations.append(ConsoleLogDestination())
        #endif
        return logger
    }()

    @objc public class func sharedInstance() -> Logger { shared }

    public var verbosity: Verbosity = .very

    // MARK: - Public

    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, file: file, function: function, line: line)
    }

    public func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, file: file, function: function, line: line)
    }

    public func error(
        _ error: Error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(String(describing: error), level: .error, file: file, function: function, line: line)
    }

    public func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        destinations.forEach {
            let statement = formatMessage(
                message,
                level: level,
                file: file,
                function: function,
                line: line
            )
            $0.log(statement: statement, level: level)
        }
    }

    // MARK: - Private

    private func formatMessage(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        switch verbosity {
        case .very:
            let timestamp = timestampFormatter.string(from: Date())
            let logLevelTitle = "\(level)".uppercased()
            return "\(timestamp) \(level.emoji) \(logLevelTitle) - \(message) \(CodeLocation(function, file, line))"
        case .some:
            return "\(level.emoji) \(message) \(CodeLocation(function, file, line))"
        case .none:
            return message
        }
    }
}
