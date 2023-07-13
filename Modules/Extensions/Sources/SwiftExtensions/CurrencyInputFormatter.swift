import Foundation

/// `CurrencyInputFormatter` is a structure used to format text input as currency. This utility supports both fiat and cryptocurrency formatting with configurable precision and decimal separator.
///
/// This structure is useful when formatting inputs from a keyboard into a currency representation in a TextField or similar UI components.
///
/// - properties:
///     - **precision**: Int to define decimal precision, default is 8 (suitable for cryptocurrencies)
///     - **decimalSeparator**: Character to be used as decimal separator, default is determined by the current locale or falls back to "."
///     - **suggestion**: Computed String property that provides a formatted currency string for display
///
/// - methods:
///     - **init(precision:decimalSeparator:)** Initializer with precision and decimal separator parameters, setting input to "0"
///     - **append(_:_)** Appends one or more Characters to the input
///     - **enter()** Does not modify the input, returns the suggestion
///     - **backspace()** Removes the last character of the input
///     - **reset()** Resets the input to "0"
///
/// Note that calling the `append` method will not append a character if it would violate the rules defined by the `isValid(character:appendingTo:)` function.
///
/// **Example**
///
///     var formatter = CurrencyInputFormatter(precision: 2)
///     formatter.append("1")  // formatter.suggestion == "1"
///     formatter.append("2")  // formatter.suggestion == "12"
///     formatter.append(".")  // formatter.suggestion == "12."
///     formatter.append("3")  // formatter.suggestion == "12.3"
///     formatter.append("4")  // formatter.suggestion == "12.34"
///     formatter.append("5")  // formatter.suggestion == "12.34"
///     formatter.backspace()  // formatter.suggestion == "12.3"
///     formatter.enter()  // == "12.3"
///     formatter.reset()  // formatter.suggestion == "0"
public struct CurrencyInputFormatter: Equatable, Hashable {

    private var input: String = "0"

    public let precision: Int
    public let decimalSeparator: Character
    public var suggestion: String { input.isEmpty ? "0" : input }

    init(
        _ input: String = "0",
        precision: Int = 8,
        decimalSeparator: Character = Character(Locale.current.decimalSeparator ?? ".")
    ) {
        self.init(precision: precision, decimalSeparator: decimalSeparator)
        self.input = input
    }

    public init(
        precision: Int = 8,
        decimalSeparator: Character = Character(Locale.current.decimalSeparator ?? ".")
    ) {
        precondition(precision > 0)
        self.precision = precision
        self.decimalSeparator = decimalSeparator
    }

    @discardableResult
    public mutating func append(_ character: Character) -> Bool {
        guard isValid(character: character, appendingTo: input) else { return false }
        if character == "0", input == "0" { return false }
        if input == "0", character != "0", character != decimalSeparator { input = "" }
        if input == "", character == decimalSeparator { input = "0" }
        input.append(character)
        return true
    }

    public func enter() -> String {
        suggestion
    }

    @discardableResult
    public mutating func backspace() -> Self {
        guard !input.isEmpty else { return self }
        input.removeLast()
        if input.last == decimalSeparator { input.removeLast() }
        return self
    }

    @discardableResult
    public mutating func reset(to input: String = "0") -> Self {
        self.input = "0"
        for character in input { append(character) }
        return self
    }

    private func isValid(character: Character, appendingTo input: String) -> Bool {
        if character == decimalSeparator { return !input.contains(decimalSeparator) }
        if character == "0" && input == "0" { return false }
        if let decimalIndex = input.firstIndex(of: decimalSeparator) {
            let digitsAfterDecimal = input.distance(from: decimalIndex, to: input.endIndex) - 1
            if digitsAfterDecimal >= precision { return false }
        }
        return character.isNumber || character == decimalSeparator
    }
}
