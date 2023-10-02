// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions
import Foundation

public struct Form: Codable, Hashable {

    public let context: String?
    public var pages: [FormPage]
    public var isLegacy: Bool = false
    public let blocking: Bool?

    public init(context: String? = nil, pages: [FormPage] = []) {
        self.context = context
        self.pages = pages
        self.blocking = pages.any { page in page.blocking ?? false }
    }

    public init(
        header: FormPage.Header? = nil,
        context: String? = nil,
        nodes: [FormQuestion],
        blocking: Bool = true
    ) {
        self.context = context
        self.pages = [.init(header: header, nodes: nodes, blocking: blocking)]
        self.isLegacy = true
        self.blocking = blocking
    }

    public var isEmpty: Bool {
        pages.first?.isEmpty ?? true
    }

    public var isValidForm: Bool {
        pages.allSatisfy(\.nodes.isValidForm)
    }

    public var isBlocking: Bool {
        blocking ?? false
    }
}

extension Form {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        if container.contains("pages") {
            self.context = try container.decodeIfPresent(String.self, forKey: "context")
            self.pages = try container.decode([FormPage].self, forKey: "pages")
            self.blocking = try container.decodeIfPresent(Bool.self, forKey: "blocking")
        } else {
            let page = try FormPage(from: decoder)
            self.context = page.context
            self.pages = [page]
            self.isLegacy = true
            self.blocking = page.blocking
        }
    }

    public func encode(to encoder: Encoder) throws {
        if isLegacy, let page = pages.first {
            try page.encode(to: encoder)
        } else {
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            try container.encode(context, forKey: "context")
            try container.encode(pages, forKey: "pages")
            try container.encode(blocking, forKey: "blocking")
        }
    }
}

public struct FormPage: Codable, Hashable, Identifiable {

    public var id: some Hashable { self }

    public struct Header: Codable, Hashable {

        public let title: String
        public let description: String

        public init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    public let header: Header?
    public let context: String?
    public var nodes: [FormQuestion]
    public let blocking: Bool?

    public var isEmpty: Bool { nodes.isEmpty }
    public var isNotEmpty: Bool { !isEmpty }

    public init(
        header: FormPage.Header? = nil,
        context: String? = nil,
        nodes: [FormQuestion],
        blocking: Bool = true
    ) {
        self.header = header
        self.context = context
        self.nodes = nodes
        self.blocking = blocking
    }
}

public struct FormQuestion: Codable, Identifiable, Hashable {

    public enum QuestionType: String, Codable {
        case singleSelection = "SINGLE_SELECTION"
        case multipleSelection = "MULTIPLE_SELECTION"
        case openEnded = "OPEN_ENDED"

        var answer: FormAnswer.AnswerType {
            FormAnswer.AnswerType(rawValue)
        }
    }

    public let id: String
    public let type: QuestionType
    public let isEnabled: Bool?
    public let isDropdown: Bool?
    public let text: String
    public let instructions: String?
    @Default<Empty> public var children: [FormAnswer]
    public var input: String?
    public let hint: String?
    public let regex: String?

    public init(
        id: String,
        type: QuestionType,
        isEnabled: Bool? = true,
        isDropdown: Bool?,
        text: String,
        instructions: String?,
        regex: String? = nil,
        input: String? = nil,
        hint: String? = nil,
        children: [FormAnswer]
    ) {
        self.id = id
        self.type = type
        self.isEnabled = isEnabled
        self.isDropdown = isDropdown
        self.text = text
        self.instructions = instructions
        self.regex = regex
        self.input = input
        self.hint = hint
        self.children = children
    }

    public var own: FormAnswer {
        get {
            FormAnswer(
                id: id,
                type: type.answer,
                isEnabled: isEnabled,
                text: nil,
                children: children,
                input: input,
                hint: hint,
                regex: regex,
                checked: nil,
                instructions: instructions
            )
        }
        set {
            input = newValue.input
        }
    }
}

extension [FormQuestion] {

    enum FormError: Error {
        case answerNotFound(FormAnswer.ID)
        case unsupportedType(String)
        case unableToDecodeValue
    }

    public func answer<T>(id: FormAnswer.ID) throws -> T? {
        let candidates = compactMap { question -> FormAnswer? in
            question.children.first(where: { $0.id == id })
        }
        guard candidates.count == 1, let answer = candidates.first else {
            throw FormError.answerNotFound(id)
        }

        let value: T?
        switch T.self {
        case is String.Type:
            value = answer.input as? T
        case is Date.Type:
            guard let input = answer.input, let timeInterval = TimeInterval(input) else {
                return nil
            }
            value = Date(timeIntervalSince1970: timeInterval) as? T
        case is Bool.Type:
            value = answer.checked as? T
        default:
            throw FormError.unsupportedType(String(describing: T.self))
        }
        return value
    }
}
