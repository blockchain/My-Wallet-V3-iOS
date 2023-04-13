// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import VGSCollectSDK

public struct VGSConfigurationBuilder {

    private let vgsCollect: VGSCollect

    init(vgsCollect: VGSCollect) {
        self.vgsCollect = vgsCollect
    }

    func cardHolderNameConfig() -> VGSConfiguration {
        let config = VGSConfiguration(
            collector: vgsCollect,
            fieldName: "card_holder_name"
        )
        config.type = .cardHolderName
        config.isRequired = true
        config.isRequiredValidOnly = true

        /// Update validation rules(default validation expects .shortYear)
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRulePattern(
                pattern: "^[a-zA-Z0-9 ,'._-]+$",
                error: VGSValidationErrorType.pattern.rawValue
            ),
            VGSValidationRuleLength(
                min: 2,
                max: 100,
                error: VGSValidationErrorType.length.rawValue
            )
        ])
        return config
    }

    func cardNumberConfig() -> VGSConfiguration {
        let config = VGSConfiguration(
            collector: vgsCollect,
            fieldName: "card_number"
        )
        config.type = .cardNumber
        config.isRequired = true
        config.isRequiredValidOnly = true
        return config
    }

    func cardExpirationConfig() -> VGSExpDateConfiguration {
        let config = VGSExpDateConfiguration(
            collector: vgsCollect,
            fieldName: "card_expirationDate"
        )

        config.type = .expDate
        config.isRequired = true
        config.isRequiredValidOnly = true
        config.inputSource = .keyboard
        config.formatPattern = "##/####"
        config.inputDateFormat = .longYear
        config.outputDateFormat = .longYear

        config.serializers = [
            VGSExpDateSeparateSerializer(
                monthFieldName: "card_exp.month",
                yearFieldName: "card_exp.year"
            )
        ]

        /// Update validation rules(default validation expects .shortYear)
        config.validationRules = VGSValidationRuleSet(rules: [
            VGSValidationRuleCardExpirationDate(
                dateFormat: .longYear,
                error: VGSValidationErrorType.expDate.rawValue
            )
        ])

        return config
    }

    func cardCVVConfig() -> VGSConfiguration {
        let config = VGSConfiguration(
            collector: vgsCollect,
            fieldName: "card_cvv"
        )
        config.type = .cvc
        config.isRequired = true
        config.isRequiredValidOnly = true
        return config
    }
}
