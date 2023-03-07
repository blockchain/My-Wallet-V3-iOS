import BlockchainComponentLibrary
import SwiftUI
import UIKit
import VGSCollectSDK

enum VGS {

    struct Input: UIViewRepresentable {

        enum DelegateCallback {
            case onReturn(VGSTextField, FieldType)
            case onDidChange(VGSTextField, FieldType)
            case onDidEndEditing(VGSTextField, FieldType)
        }

        struct Field {
            let name: String
            let type: FieldType
        }

        init(
            type field: Field,
            collector: VGSCollect,
            onDelegateCallback: @escaping (DelegateCallback) -> Void,
            placeholder: String? = nil,
            isRequired: Bool = true,
            isSecure: Bool = false,
            vgsConfiguration: VGSConfiguration,
            isValid: Binding<Bool> = .constant(true)
        ) {
            self.field = field
            self.collector = collector
            self.placeholder = placeholder
            self.isRequired = isRequired
            self.isSecure = isSecure
            self.vgsConfiguration = vgsConfiguration
            _isValid = isValid
            self.onDelegateCallback = onDelegateCallback
        }

        var field: Field
        var placeholder: String?
        var vgsConfiguration: VGSConfiguration
        var isRequired: Bool = true
        var isSecure: Bool = false

        private var collector: VGSCollect
        private var onDelegateCallback: (DelegateCallback) -> Void

        @Binding var isValid: Bool

        func makeUIView(context: Context) -> VGSTextField {
            switch field.type {
            case .cardNumber:
                return VGSCardTextField()
            case .expDate:
                return VGSExpDateTextField()
            case .cvc:
                return VGSCVCTextField()
            default:
                return VGSTextField()
            }
        }

        func updateUIView(_ input: VGSTextField, context: Context) {
            input.font = UIFont(
                name: Typography.FontResource.interMedium.rawValue,
                size: 16
            )
            input.textColor = UIColor(Color.semantic.text)
            input.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            input.textAlignment = .natural
            input.borderColor = isValid ? UIColor(Color.semantic.medium) : UIColor(Color.semantic.error)
            input.tintColor = UIColor(Color.semantic.muted)
            input.placeholder = placeholder
            input.isSecureTextEntry = isSecure
            input.delegate = context.coordinator
            input.configuration = vgsConfiguration

            input.setContentHuggingPriority(.defaultHigh, for: .vertical)
            input.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }

        func makeCoordinator() -> TextFieldDelegate {
            TextFieldDelegate(parent: self)
        }

        class TextFieldDelegate: VGSTextFieldDelegate {

            let parent: Input

            init(parent: Input) {
                self.parent = parent
            }

            func vgsTextFieldDidEndEditing(_ textField: VGSTextField) {
                parent.onDelegateCallback(.onDidEndEditing(textField, parent.field.type))
            }

            func vgsTextFieldDidChange(_ textField: VGSTextField) {
                textField.borderColor = UIColor(Color.semantic.medium)
                parent.onDelegateCallback(.onDidChange(textField, parent.field.type))
            }

            func vgsTextFieldDidEndEditingOnReturn(_ textField: VGSTextField) {
                parent.onDelegateCallback(.onReturn(textField, parent.field.type))
            }
        }
    }
}

extension VGS.Input {

    struct Configuration {
        var field: Field
        var placeholder: String?
        var vgsConfiguration: VGSConfiguration
        var isSecure: Bool
        var isRequired: Bool
    }

    init(
        configuration: Configuration,
        isValid: Binding<Bool>,
        collector: VGSCollect,
        onDelegateCallback: @escaping (DelegateCallback) -> Void
    ) {
        self.init(
            type: configuration.field,
            collector: collector,
            onDelegateCallback: onDelegateCallback,
            placeholder: configuration.placeholder,
            isRequired: configuration.isRequired,
            isSecure: configuration.isSecure,
            vgsConfiguration: configuration.vgsConfiguration,
            isValid: isValid
        )
    }
}

extension VGS.Input.Configuration {

    static func cardHolderName(vgsConfigurationBuilder: VGSConfigurationBuilder) -> Self {
        Self(
            field: .cardHolderName,
            vgsConfiguration: vgsConfigurationBuilder.cardHolderNameConfig(),
            isSecure: false,
            isRequired: true
        )
    }

    static func cardNumber(vgsConfigurationBuilder: VGSConfigurationBuilder) -> Self {
        Self(
            field: .cardNumber,
            vgsConfiguration: vgsConfigurationBuilder.cardNumberConfig(),
            isSecure: false,
            isRequired: true
        )
    }

    static func cardExpiration(vgsConfigurationBuilder: VGSConfigurationBuilder) -> Self {
        Self(
            field: .cardExpirationDate,
            placeholder: "HH/YYYY",
            vgsConfiguration: vgsConfigurationBuilder.cardExpirationConfig(),
            isSecure: false,
            isRequired: true
        )
    }

    static func cardCVV(vgsConfigurationBuilder: VGSConfigurationBuilder) -> Self {
        Self(
            field: .cvv,
            vgsConfiguration: vgsConfigurationBuilder.cardCVVConfig(),
            isSecure: false,
            isRequired: true
        )
    }
}

extension VGS.Input.Field {
    static let cardHolderName = Self(name: "card_holder_name", type: .cardHolderName)
    static let cardNumber = Self(name: "card_number", type: .cardNumber)
    static let cardExpirationDate = Self(name: "card_expirationDate", type: .expDate)
    static let cvv = Self(name: "card_cvv", type: .cvc)
}

extension VGSValidationRulePattern {

    init(_ pattern: String) {
        self.init(pattern: pattern, error: VGSValidationErrorType.pattern.string)
    }
}

extension VGSValidationRuleLength {

    init(min: Int = 0, max: Int = Int.max) {
        self.init(min: min, max: max, error: VGSValidationErrorType.length.string)
    }

    init(_ range: ClosedRange<Int>) {
        self.init(min: range.lowerBound, max: range.upperBound)
    }
}
