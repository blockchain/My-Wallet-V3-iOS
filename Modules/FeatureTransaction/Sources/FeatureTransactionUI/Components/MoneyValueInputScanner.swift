// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

/// This class processes number input into a valid money value output.
/// This class is money agnostic and therefore can scan crypto as well
/// as fiat.
public final class MoneyValueInputScanner {

    // MARK: - Types

    /// Structure describing the maximum amount of digits in a decimal number integral and fractional parts.
    public struct MaxDigits {
        let integral: Int
        let fractional: Int

        init(integral: Int, fractional: Int) {
            self.integral = integral
            self.fractional = fractional
        }
    }

    /// An action to be performed on the input
    public enum Action {

        /// Removes a single character at the last indexed position
        case remove

        /// Inserts a given character at the last indexed position
        case insert(Character)
    }

    /// Represents an input
    public struct Input: Equatable {

        /// A string input
        public let string: String

        /// A caret index of the next input
        let caretIndex: Int

        /// The amount string (prefix) - this is the first part of the input which
        /// has been already inserted.
        var amount: String {
            guard !string.isEmpty else {
                return "0"
            }

            let amount = String(string[0..<caretIndex])
            return amount
        }

        /// Returns true if empty
        var isEmptyOrPlaceholderZero: Bool {
            isPlaceholderZero || isEmpty
        }

        /// Returns true if a zero but not empty (not a placeholder)
        var isUserInputZero: Bool {
            self == .userInputZero
        }

        /// Returns true if a zero placeholder
        var isPlaceholderZero: Bool {
            self == .placeholderZero
        }

        /// Empty input
        var isEmpty: Bool {
            self == .empty
        }

        /// Empty input
        static var empty: Input {
            Input(string: "", caretIndex: 0)
        }

        /// Zero placeholder input
        static var placeholderZero: Input {
            Input(string: Constant.zero, caretIndex: 0)
        }

        /// Zero user input
        static var userInputZero: Input {
            Input(string: Constant.zero, caretIndex: 1)
        }

        init(string: String, caretIndex: Int) {
            self.string = string
            self.caretIndex = caretIndex
        }

        /// The padding string (suffix) - i.e the last part of the input which
        /// is yet to be inserted. might be empty in which case, the string
        /// is either full. e.g for values of `21.51` or `21`
        /// `padding` would be equal `nil`.
        var padding: String? {
            guard !isUserInputZero else {
                return nil
            }
            guard caretIndex < string.count else {
                return nil
            }
            return String(string[caretIndex..<string.count])
        }

        public init(string: String) {
            self.string = string
            self.caretIndex = string.count
        }

        public init(decimal: Decimal) {
            self.init(string: "\(decimal)")
        }
    }

    public enum Constant {
        public static let decimalSeparator = Locale.current.decimalSeparator ?? "."
        fileprivate static let decimalSeparatorChar = Character(decimalSeparator)
        fileprivate static let zero = "0"
        fileprivate static let zeroChar = Character(zero)
        fileprivate static let allowedCharacters: CharacterSet = {
            var decimalDigits = CharacterSet.decimalDigits
            decimalDigits.insert(Constant.decimalSeparatorChar.unicodeScalars.first!)
            return decimalDigits
        }()
    }

    /// A current digit to be added to the input
    public let actionRelay = PublishRelay<Action>()

    /// Streams the input
    public var input: Observable<Input> {
        internalInputRelay
            .asObservable()
            .distinctUntilChanged()
    }

    /// Can be used by clients to stream in raw String inputs
    /// That input is to be analyzed internally and populate the main
    /// input relay
    public let rawInputRelay = PublishRelay<String>()

    // MARK: - Private Properties

    public let maxDigitsRelay: BehaviorRelay<MaxDigits>
    let internalInputRelay = BehaviorRelay(value: Input.empty)
    private let disposeBag = DisposeBag()

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = Constant.decimalSeparator
        formatter.maximumFractionDigits = CurrencyType.maxDisplayPrecision
        return formatter
    }()

    // MARK: - Setup

    public init(maxDigits: MaxDigits) {
        self.maxDigitsRelay = BehaviorRelay(value: maxDigits)

        actionRelay
            .map(weak: self) { (self, action) in
                self.scan(action: action)
            }
            .bindAndCatch(to: internalInputRelay)
            .disposed(by: disposeBag)

        maxDigitsRelay
            .bindAndCatch(weak: self) { (self, _) in
                self.reset()
            }
            .disposed(by: disposeBag)

        rawInputRelay
            .asSignal()
            .emit(
                onNext: { [weak self] input in
                    self?.reset(to: input)
                }
            )
            .disposed(by: disposeBag)
    }

    public func reset(to moneyValue: MoneyValue) {
        let amount = moneyValue.displayMajorValue
        reset(to: amount)
    }

    /// Resets the input to a single `0` character.
    public func reset(to string: String = "") {
        guard let amount = Decimal(string: string) else { return }
        reset(to: amount)
    }

    private func reset(to decimal: Decimal) {
        guard let value = formatter.string(from: decimal as NSNumber) else { return }
        let input = parse(amount: value)
        internalInputRelay.accept(input)
    }

    // MARK: - Accessors

    private func scan(action: Action) -> Input {
        switch action {
        case .insert(let character):
            insert(character: character)
        case .remove:
            removeIndexed()
        }
    }

    /// Removes the last indexed character from the cached value
    private func removeIndexed() -> Input {
        let lastInput = internalInputRelay.value
        let lastValue = lastInput.string

        /// input is `` or `0` -> just return previous value
        if lastInput == .userInputZero ||
            lastInput == .placeholderZero ||
            lastInput == .init(string: "0\(Constant.decimalSeparator)", caretIndex: 2)
        {
            return .placeholderZero
        }

        /// input is a single digit -> just return `0`
        guard lastValue.count > 1 else {
            return .placeholderZero
        }

        var newValue = lastValue

        let range = newValue.range(
            startingAt: lastInput.caretIndex - 1,
            length: newValue.count - lastInput.caretIndex + 1
        )!
        newValue.removeSubrange(range)
        let caretIndex = lastInput.caretIndex - 1

        padRhsIfNeeded(value: &newValue)

        return Input(string: newValue, caretIndex: caretIndex)
    }

    /// Inserts a new character into the cached value
    /// Steps:
    /// 1. Validates the new character
    /// 2. Validates empty string
    /// 3. Inserts the new character at the position the caret points to
    /// 4. Pads the RHS if needed.
    /// 5. Validate the maximum length of values before and after the separator
    private func insert(character: Character) -> Input {

        ////////////////////////////////////////////////
        /// **Character validation**
        /// Validate digit or decimal-separator

        var lastInput = internalInputRelay.value

        guard Constant.allowedCharacters.contains(character) else {
            return lastInput
        }

        ////////////////////////////////////////////////
        /// **Empty Input Validation**
        /// All possible cases of an empty input, where
        /// nothing should actually be changed

        var lastValue = lastInput.string

        /// Current character is `.` and the string so far already contains `.`
        if lastValue.contains(Constant.decimalSeparator), character.isDecimalSeparator {
            /// `12.30` + `.` = `12.30`
            return lastInput
            /// Empty / Placeholder zero && The new character is the decimal separator -> move the caret before
            /// further processing
        } else if lastInput.isEmptyOrPlaceholderZero {
            if character.isDecimalSeparator {
                lastInput = Input(string: Constant.zero, caretIndex: 1)
                lastValue = lastInput.string
            } else if character == Constant.zeroChar {
                /// `0` + `0` = `0`
                /// `` + `0` = `0`
                return .userInputZero
            }
        } else if lastInput.isUserInputZero, character == Constant.zeroChar {
            return .userInputZero
        }

        ////////////////////////////////////////////////
        /// **String Replacement**
        /// Append or replace a new character `[0-9\.]` depending on
        /// where the caret index points to.

        var newValue: String

        /// If the caret value is located at the end of the string,
        /// then just append `newCharacter` to `lastValue`
        if lastInput.caretIndex == lastValue.count {
            newValue = lastValue + "\(character)"
        } else {
            /// If the caret index is within the string,
            /// then replace the character which `lastInput.caretIndex` points to
            newValue = lastValue
            let range = Range(NSRange(location: lastInput.caretIndex, length: 1), in: newValue)!
            newValue.replaceSubrange(range, with: "\(character)")
        }

        /// Increment the caret index
        let newCaretIndex = lastInput.caretIndex + 1

        /// **RHS Padding (if needed) **
        /// We should pad the RHS component if its length is less than `maxFractionDigits`

        /// Separate the compound input into two components if possible: `[LHS, RHS]`
        padRhsIfNeeded(value: &newValue)

        ////////////////////////////////////////////////
        /// **Max Length Validation**
        /// If the input so far contains `.`.
        /// That would place the current digit to the right of the floating point.
        /// Therefore we would like to verify that there are no more than `maxFractionDigits` digits
        /// in the RHS number component.

        /// Re-separate `newValue` to components is it has possibly changed
        /// by a newly added padding
        let components = newValue.components(separatedBy: Constant.decimalSeparator)

        // Reached maximum number of digits before decimal separator [integral part]
        guard components[0].count <= maxDigitsRelay.value.integral else {
            return Input(string: lastValue)
        }

        // Reached maximum number of digits after the decimal separator [fractional part]
        if components.count == 2 {
            let rhs = components[1]
            if rhs.count != maxDigitsRelay.value.fractional {
                return Input(string: lastValue)
            }
        }

        return Input(string: newValue, caretIndex: newCaretIndex)
    }

    private func padRhsIfNeeded(value: inout String) {
        let components = value.components(separatedBy: Constant.decimalSeparator)
        guard components.count == 2 else {
            return
        }

        let rhs = components[1]
        let padCount = maxDigitsRelay.value.fractional - rhs.count
        guard padCount > 0 else {
            return
        }
        let padding = Array(repeating: Constant.zero, count: padCount).joined()
        value.append(padding)
    }

    /// Parses a given string to an Input struct
    ///
    /// - Parameter value: The value of the given amount.
    /// - Returns: An `Input` struct containing the parsed value.
    func parse(amount value: String) -> Input {
        let components: [String] = value
            .split(separator: Character(Constant.decimalSeparator))
            .map { component in
                var component = String(component)
                component.removeAll(where: { !CharacterSet.decimalDigits.contains($0) })
                return component
            }

        let input: Input
        if components.isEmpty {
            input = .placeholderZero
        } else {
            var string = String(components[0].prefix(maxDigitsRelay.value.integral))
            if components.count > 1 {
                string += "\(Constant.decimalSeparator)\(components[1].prefix(maxDigitsRelay.value.fractional))"
            }
            input = .init(string: string)
        }
        return input
    }
}

extension Character {
    fileprivate var isDecimalSeparator: Bool {
        self == MoneyValueInputScanner.Constant.decimalSeparatorChar
    }
}
