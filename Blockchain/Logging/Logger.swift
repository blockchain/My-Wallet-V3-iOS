//
//  Logger.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Class in charge of logging debug/info/warning/error messages to a `LogDestination`.
@objc class Logger: NSObject {

    private var destinations = [LogDestination]()

    static let shared: Logger = {
        let logger = Logger()
        #if DEBUG
        logger.destinations.append(ConsoleLogDestination())
        #endif
        return logger
    }()

    @objc class func sharedInstance() -> Logger { return shared }

    func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, file: file, function: function, line: line)
    }

    func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, file: file, function: function, line: line)
    }

    func log (
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
            $0.log(statement: statement)
        }
    }

    private func formatMessage(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        let logLevelTitle = "\(level)".uppercased()
        return "\(level.emoji) \(logLevelTitle) \(filename(from: file)).\(function):\(line) - \(message)"
    }

    private func filename(from file: String) -> String {
        if let lastComponent = file.components(separatedBy: "/").last {
            return lastComponent.components(separatedBy: ".").first ?? lastComponent
        }
        return file
    }
}
