// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Sequence<Substring> {
    @inlinable public var string: [String] { map(\.string) }
}

extension String {

    @inlinable public subscript(ns: NSRange) -> SubSequence {
        guard let range = Range<String.Index>(ns, in: self) else { fatalError("Out of bounds") }
        return self[range]
    }
}

extension StringProtocol {

    @inlinable public func dropPrefix(_ contents: some StringProtocol) -> SubSequence {
        hasPrefix(contents) ? self[index(startIndex, offsetBy: contents.count)...] : self[...]
    }

    @inlinable public func dropSuffix(_ contents: some StringProtocol) -> SubSequence {
        hasSuffix(contents) ? self[..<index(endIndex, offsetBy: -contents.count)] : self[...]
    }
}

extension StringProtocol {
    @inlinable public var substring: SubSequence { self[...] }
    @inlinable public var string: String { String(self) }
}

extension StringProtocol {

    public func interpolating(_ args: CVarArg...) -> String {
        String(format: string, arguments: args)
    }
}

extension StaticString {

    @inlinable public var string: String {
        hasPointerRepresentation
        ? withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
        : .init(unicodeScalar)
    }
}

// swiftlint:disable let_var_whitespace
public protocol NewTypeString: Codable, Hashable, Comparable, ExpressibleByStringLiteral, LosslessStringConvertible {
    var value: String { get }
    init(_ value: String)
}

extension NewTypeString {
    public init(stringLiteral value: String) { self.init(value) }
}

extension NewTypeString {
    public init(from decoder: Decoder) throws { try self.init(String(from: decoder)) }
    public func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
}

extension NewTypeString {
    public var description: String { value }
    public init?(_ description: String) { self.init(description) }
}

extension NewTypeString {
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.value < rhs.value }
}

extension String {

    @inlinable public func snakeCase() -> String {
        guard !isEmpty else { return self }

        var words: [Range<String.Index>] = []
        var start = startIndex
        var search = index(after: start)..<endIndex

        while let upperCaseRange = rangeOfCharacter(from: CharacterSet.uppercaseLetters, range: search) {
            let untilUpperCase = start..<upperCaseRange.lowerBound
            words.append(untilUpperCase)

            search = upperCaseRange.lowerBound..<search.upperBound
            guard let lowerCaseRange = rangeOfCharacter(from: CharacterSet.lowercaseLetters, range: search) else {
                start = search.lowerBound
                break
            }

            let nextCharacterAfterCapital = index(after: upperCaseRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                start = upperCaseRange.lowerBound
            } else {
                let beforeLowerIndex = index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)
                start = beforeLowerIndex
            }
            search = lowerCaseRange.upperBound..<search.upperBound
        }
        words.append(start..<search.upperBound)
        return words
            .map { self[$0].lowercased() }
            .joined(separator: "_")
    }
}

extension NSRegularExpression {

    public convenience init(_ pattern: StaticString) {
        do {
            try self.init(pattern: pattern.string)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension NSRegularExpression {

    public func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension String {

    public static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        return regex.matches(lhs)
    }

    public static func ~= (lhs: String, rhs: StaticString) -> Bool {
        NSRegularExpression(rhs).matches(lhs)
    }
}

extension String {

    public func error(
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) -> Error {
        .init(message: self, function: function, file: file, line: line)
    }

    public struct Error: Swift.Error, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {

        let message: String
        let function: String
        let file: String
        let line: Int

        public var description: String { message }
        public var debugDescription: String { "\(message) ← \(file)#\(line)" }

        public var errorDescription: String? { description }
        public var recoverySuggestion: String? { description }
        public var helpAnchor: String? { description }
        public var failureReason: String? { description }
    }
}

extension String.Error {

    public init(
        _ error: Any,
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) {
        self.init(message: error as? String ?? String(describing: error), function: function, file: file, line: line)
    }
}

extension String.Error: Equatable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(message)
    }

    public static func == (lhs: String.Error, rhs: String.Error) -> Bool {
        lhs.message == rhs.message
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { self }
    public var recoverySuggestion: String? { self }
    public var helpAnchor: String? { self }
    public var failureReason: String? { self }
}


extension String {
    public func obfuscate(keeping n: Int) -> String {
        guard self.count > n * 2 else { return self }
        let first = String(self.prefix(n))
        let last = String(self.suffix(n))
        return first + "..." + last
    }
}
