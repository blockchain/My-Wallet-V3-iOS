//
//  TextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import LocalizationKit

/// A view model for text field
public class TextFieldViewModel {
    
    struct GestureMessage: Equatable {
        let message: String
        let isVisible: Bool
    }
    
    // MARK: Properties

    /// The state of the text field
    public var state: Observable<State> {
        return stateRelay.asObservable()
    }
    
    /// Should text field gain focus or remove
    public let focusRelay = PublishRelay<Bool>()
    
    /// The contentType of the `UITextField`
    var contentType: Driver<UITextContentType?> {
        return contentTypeRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The isSecureTextEntry of the `UITextField`
    var isSecure: Driver<Bool> {
        return isSecureRelay.asDriver()
    }
    
    /// The placeholder of the text-field
    var placeholder: Driver<NSAttributedString> {
        return placeholderRelay.asDriver()
    }
    
    /// The color of the content (.mutedText, .textFieldText)
    var textColor: Driver<UIColor> {
        return textColorRelay.asDriver()
    }
        
    /// A text to display below the text field in case of an error
    var gestureMessage: Driver<GestureMessage> {
        return Driver
            .combineLatest(hintRelay.asDriver(), isHintVisibleRelay.asDriver())
            .map {
                GestureMessage(
                    message: $0.0,
                    isVisible: $0.1
                )
            }
            .distinctUntilChanged()
    }
        
    /// The content of the text field
    let textRelay = BehaviorRelay<String>(value: "")
    var text: Observable<String> {
        return textRelay
            .distinctUntilChanged()
    }
    
    let isHintVisibleRelay = BehaviorRelay(value: false)
    
    let font = UIFont.mainMedium(16)
    
    private let contentTypeRelay: BehaviorRelay<UITextContentType?>
    private let isSecureRelay = BehaviorRelay(value: false)
    private let placeholderRelay: BehaviorRelay<NSAttributedString>
    private let textColorRelay = BehaviorRelay<UIColor>(value: .textFieldText)
    private let hintRelay = BehaviorRelay<String>(value: "")
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    let validator: TextValidating
    let textMatcher: CollectionTextMatchValidator?
    let type: TextFieldType
    let accessibility: Accessibility

    // MARK: - Setup
    
    public init(with type: TextFieldType,
                validator: TextValidating,
                textMatcher: CollectionTextMatchValidator? = nil) {
        self.validator = validator
        self.textMatcher = textMatcher
        self.type = type
        
        let placeholder = NSAttributedString(
            string: type.placeholder,
            attributes: [
                .foregroundColor: UIColor.textFieldPlaceholder,
                .font: font
            ]
        )
        placeholderRelay = BehaviorRelay(value: placeholder)
        contentTypeRelay = BehaviorRelay(value: type.contentType)
        isSecureRelay.accept(type.isSecure)
        accessibility = type.accessibility

        text
            .bind(to: validator.valueRelay)
            .disposed(by: disposeBag)
        
        let hasMatch: Observable<Bool>
        if let textMatcher = textMatcher {
            hasMatch = textMatcher.isValid
        } else {
            hasMatch = .just(true)
        }
        
        Observable
            .combineLatest(hasMatch, validator.isValid, text.asObservable())
            .map { (hasMatch, isValid, text) in
                return State(hasMatch: hasMatch, validationPasses: isValid, text: text)
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        state
            .map { state -> String in
                switch state {
                case .empty, .valid:
                    return "" // No text representation
                case .invalid:
                    switch type {
                    case .email:
                        return LocalizationConstants.TextField.Gesture.invalidEmail
                    case .recoveryPhrase:
                        return LocalizationConstants.TextField.Gesture.invalidRecoveryPhrase
                    case .newPassword,
                         .confirmNewPassword,
                         .password:
                        return ""
                    case .walletIdentifier:
                        return LocalizationConstants.TextField.Gesture.walletId
                    }
                case .mismatchError:
                    switch type {
                    case .confirmNewPassword, .newPassword:
                        return LocalizationConstants.TextField.Gesture.passwordMismatch
                    case .email, .password, .walletIdentifier, .recoveryPhrase:
                        return ""
                    }
                }
            }
            .bind(to: hintRelay)
            .disposed(by: disposeBag)
    }
    
    func textFieldDidEndEditing() {
        isHintVisibleRelay.accept(true)
    }
    
    /// Should be called upon editing the text field
    func textFieldEdited(with value: String) {
        textRelay.accept(value)
        isHintVisibleRelay.accept(type.showsHintWhileTyping)
    }
}

// MARK: - State

extension TextFieldViewModel {
    
    /// A state of a single text field
    public enum State {
        
        /// Valid state - validation is passing
        case valid(value: String)
        
        /// Empty field
        case empty
        
        /// Mismatch error
        case mismatchError
        
        /// Invalid state - validation is not passing.
        case invalid
    
        /// Returns the text value if there is a valid value
        public var value: String? {
            switch self {
            case .valid(value: let value):
                return value
            default:
                return nil
            }
        }
        
        /// Reducer for possible validation states
        init(hasMatch: Bool, validationPasses: Bool, text: String) {
            guard !text.isEmpty else {
                self = .empty
                return
            }
            switch (hasMatch, validationPasses, text) {
            case (true, true, let text):
                self = .valid(value: text)
            case (false, _, text):
                self = .mismatchError
            case (_, false, _):
                self = .invalid
            default:
                self = .invalid
            }
        }
    }
}

// MARK: - Equatable (Lossy - only the state, without associated values)

extension TextFieldViewModel.State: Equatable {
    public static func == (lhs: TextFieldViewModel.State,
                           rhs: TextFieldViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid),
             (.mismatchError, .mismatchError),
             (.invalid, .invalid),
             (.empty, .empty):
            return true
        default:
            return false
        }
    }
}
