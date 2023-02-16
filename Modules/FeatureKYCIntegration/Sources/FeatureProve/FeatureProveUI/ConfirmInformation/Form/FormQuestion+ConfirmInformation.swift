// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureFormDomain
import FeatureProveDomain
import Localization
import ToolKit

private typealias LocalizedFormString = LocalizationConstants.ConfirmInformation.Body.Form

extension FormQuestion {

    static func confirmInformation(
        firstName: String?,
        lastName: String?,
        addresses: [Address],
        selectedAddress: Address?,
        dateOfBirth: Date?,
        phone: String?
    ) -> [FormQuestion] {
        [
            FormQuestion(
                id: ConfirmInformation.InputField.firstName.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedFormString.firstNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.firstName.rawValue,
                        type: .openEnded,
                        input: firstName,
                        hint: LocalizedFormString.firstNameInputPlaceholder
                    )
                ]
            ),
            FormQuestion(
                id: ConfirmInformation.InputField.lastName.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedFormString.lastNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.lastName.rawValue,
                        type: .openEnded,
                        input: lastName,
                        hint: LocalizedFormString.lastNameInputPlaceholder
                    )
                ]
            ),
            addressQuestion(addresses: addresses, selectedAddress: selectedAddress),
            FormQuestion(
                id: ConfirmInformation.InputField.dateOfBirth.rawValue,
                type: .openEnded,
                isEnabled: false,
                isDropdown: false,
                text: LocalizedFormString.dateOfBirthInputTitle,
                instructions: LocalizedFormString.dateOfBirthInputHint,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.dateOfBirth.rawValue,
                        type: .date,
                        isEnabled: false,
                        validation: FormAnswer.Validation(
                            rule: .withinRange,
                            metadata: [
                                .maxValue: String(
                                    (Calendar.current.eighteenYearsAgo ?? Date()).timeIntervalSince1970
                                )
                            ]
                        ),
                        text: nil,
                        input: dateOfBirth?.timeIntervalSince1970.description
                    )
                ]
            ),
            FormQuestion(
                id: ConfirmInformation.InputField.phone.rawValue,
                type: .openEnded,
                isEnabled: false,
                isDropdown: false,
                text: LocalizedFormString.phoneInputTitle,
                instructions: LocalizedFormString.phoneInputHint,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.phone.rawValue,
                        type: .openEnded,
                        isEnabled: false,
                        input: phone
                    )
                ]
            )
        ]
    }

    fileprivate static func addressQuestion(
        addresses: [Address],
        selectedAddress: Address?
    ) -> FormQuestion {
        if addresses.isEmpty {
            return FormQuestion(
                id: ConfirmInformation.InputField.emptyAddressAnswerId,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedFormString.addressNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.emptyAddressAnswerId,
                        type: .openEnded,
                        input: "",
                        hint: LocalizedFormString.addressInputPlaceholder
                    )
                ]
            )
        } else if addresses.count == 1 {
            return FormQuestion(
                id: ConfirmInformation.InputField.address.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedFormString.addressNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.address.rawValue,
                        type: .openEnded,
                        input: selectedAddress?.text,
                        hint: LocalizedFormString.addressInputPlaceholder
                    )
                ]
            )
        } else {
            let answers: [FormAnswer] = addresses.enumerated().map { index, address in
                FormAnswer(
                    id: ConfirmInformation.InputField.addressAnswerId(index: index),
                    type: .selection,
                    text: address.text,
                    checked: address == selectedAddress
                )
            }
            return FormQuestion(
                id: ConfirmInformation.InputField.address.rawValue,
                type: .singleSelection,
                isDropdown: true,
                text: LocalizedFormString.addressNameInputTitle,
                instructions: nil,
                children: answers
            )
        }
    }
}

extension Address {
    fileprivate var text: String {
        let stateAndPostalCode = [
            state?.replacingOccurrences(of: Constants.usPrefix, with: ""),
            postCode
        ]
            .compactMap { $0 }
            .filter(\.isNotEmpty)
            .joined(separator: " ")

        return [
            line1,
            line2,
            city,
            stateAndPostalCode
        ]
            .compactMap { $0 }
            .filter(\.isNotEmpty)
            .joined(separator: ", ")
    }
}
