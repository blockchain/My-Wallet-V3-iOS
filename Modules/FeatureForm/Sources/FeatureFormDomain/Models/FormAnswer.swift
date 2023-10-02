// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions

public struct FormAnswer: Codable, Hashable, Identifiable {

    public struct AnswerType: NewTypeString {
        public let value: String
        public init(_ value: String) { self.value = value }
        /// An answer's `input` field is set to be a `String` representation of a `TimeInterval`.
        /// Use that value to transform the `input` field into a `Date` and vice-versa.
        /// The date can be validated using a validation rule. Otherwise, any input would be considered valid.
        public static let date: Self = "DATE"
        /// A `selection` answer needs to have the value `checked` set.
        public static let selection: Self = "SELECTION"
        /// An `openEnded` answer needs to have a non-empty `input`.
        public static let openEnded: Self = "OPEN_ENDED"
    }

    public struct Validation: Hashable, Codable {

        public enum Rule: String, Equatable, Codable {
            /// Requires that the `input` field is set to a non-empty `String`.
            case notEmpty = "NOT_EMPTY"
            /// Requires that the `checked` value to be set to `true`.
            case selected = "SELECTED"
            /// Requires that the input is within a range. The range can be defined using the `metadata` property of the `Validation`.
            /// If no `minValue` nor `maxValue` is provided, the `input` will be valid as long as it represents a `TimeInterval`.
            ///
            /// This rule can only be applied to a `date` answer type, at the moment and will be ignored for other input fields.
            /// In that case the `notEmpty` rule will be applied instead.
            case withinRange = "RANGE"
        }

        public enum MetadataKey: String, Hashable, Codable {
            case minValue
            case maxValue
        }

        public let rule: Rule
        public let metadata: [MetadataKey: String]?

        public init(rule: Rule, metadata: [MetadataKey: String]? = nil) {
            self.rule = rule
            self.metadata = metadata
        }
    }

    public let id: String
    public let type: AnswerType
    public let isEnabled: Bool?
    public let validation: Validation?
    public let text: String?
    public var children: [FormAnswer]?
    public var input: String?
    public var prefixInputText: String?
    public var hint: String?
    public var instructions: String?
    public let regex: String?
    public var checked: Bool?

    public var isSelection: Bool {
        type == .selection
    }

    public init(
        id: String,
        type: AnswerType,
        isEnabled: Bool? = true,
        validation: Validation? = nil,
        text: String? = nil,
        children: [FormAnswer]? = nil,
        input: String? = nil,
        prefixInputText: String? = nil,
        hint: String? = nil,
        regex: String? = nil,
        checked: Bool? = nil,
        instructions: String? = nil
    ) {
        self.id = id
        self.type = type
        self.isEnabled = isEnabled
        self.validation = validation
        self.text = text
        self.children = children
        self.input = input
        self.prefixInputText = prefixInputText
        self.hint = hint
        self.regex = regex
        self.checked = checked
        self.instructions = instructions
    }
}
