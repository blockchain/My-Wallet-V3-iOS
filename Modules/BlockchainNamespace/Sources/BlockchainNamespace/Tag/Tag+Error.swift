// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Tag {

    public struct Error: Swift.Error, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {

        let event: Tag.Event
        let context: Tag.Context

        let message: String
        let file: String, line: Int

        init(
            event: Tag.Event,
            context: Tag.Context = [:],
            message: @autoclosure () -> String = "",
            _ file: String = #fileID,
            _ line: Int = #line
        ) {
            self.event = event
            self.context = context
            self.message = message()
            self.file = file
            self.line = line
        }

        public var description: String { message }
        public var errorDescription: String? { message }

        public var debugDescription: String {
            "\(file):\(line) \(event): \(message)"
        }
    }

    public enum Indexing {

        public struct Error: Swift.Error, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {

            let missing: String
            let tag: Tag.ID
            let file: String, line: Int

            init(
                missing: String,
                tag: Tag.ID,
                _ file: String = #fileID,
                _ line: Int = #line
            ) {
                self.missing = missing
                self.tag = tag
                self.file = file
                self.line = line
            }

            public var description: String { "Missing index \(missing) in \(tag)" }
            public var errorDescription: String? { description }

            public var debugDescription: String {
                "\(file):\(line) -> \(description)"
            }
        }
    }
}

extension Tag.Event {

    public func error(
        message: @autoclosure () -> String = "",
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) -> Tag.Error {
        .init(event: self, context: context, message: message(), file, line)
    }
}
