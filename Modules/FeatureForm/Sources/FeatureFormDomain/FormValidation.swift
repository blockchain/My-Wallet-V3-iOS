// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions
import Foundation

extension FormQuestion {

    public var isValid: Bool {
        let isValid: Bool
        switch type {
        case .singleSelection:
            let selections = children.filter { $0.checked == true }
            isValid = selections.count == 1 && selections.hasAllValidAnswers
        case .multipleSelection:
            let selections = children.filter { $0.checked == true }
            isValid = selections.count >= 1 && selections.hasAllValidAnswers
        case .openEnded where children.isNotEmpty:
            isValid = children.hasAllValidAnswers
        case .openEnded:
            if let regex {
                isValid = input.emptyIfNil ~= regex
            } else {
                isValid = input.isNilOrEmpty
            }
        }
        return isValid
    }
}

extension FormAnswer {

    public var isValid: Bool {
        var isValid = false
        if let validation {
            switch validation.rule {
            case .selected:
                isValid = checked == true
            case .withinRange where type == .date:
                let minValue = validation.metadata?[.minValue] ?? ""
                let maxValue = validation.metadata?[.maxValue] ?? ""
                if let input {
                    isValid = isValidDate(input: input, minValue: minValue, maxValue: maxValue)
                } else {
                    isValid = false
                }
            default:
                isValid = input?.isEmpty == false
            }
        } else {
            switch type {
            case .selection:
                isValid = checked == true
            case .openEnded, .date:
                isValid = input?.isEmpty == false
            default:
                isValid = checked == true || input.isNotNilOrEmpty
            }
        }

        if let children {
            isValid = isValid && children.hasAllValidAnswers
        }
        if let regex {
            isValid = isValid && input.emptyIfNil ~= regex
        }

        return isValid
    }

    private func isValidDate(input: String, minValue: String, maxValue: String) -> Bool {
        guard let input = TimeInterval(input) else {
            return false
        }
        let isValid: Bool
        let inputDate = Date(timeIntervalSince1970: input)
        if let minValue = TimeInterval(minValue), let maxValue = TimeInterval(maxValue) {
            let minDate = Date(timeIntervalSince1970: minValue)
            let maxDate = Date(timeIntervalSince1970: maxValue)
            isValid = inputDate >= minDate && inputDate <= maxDate
        } else if let minValue = TimeInterval(minValue) {
            let minDate = Date(timeIntervalSince1970: minValue)
            isValid = inputDate >= minDate
        } else if let maxValue = TimeInterval(maxValue) {
            let maxDate = Date(timeIntervalSince1970: maxValue)
            isValid = inputDate <= maxDate
        } else {
            isValid = true
        }

        return isValid
    }
}

extension [FormAnswer] {

    var hasAllValidAnswers: Bool {
        allSatisfy(\.isValid)
    }
}

extension [FormQuestion] {

    public var isValidForm: Bool {
        allSatisfy(\.isValid)
    }
}
