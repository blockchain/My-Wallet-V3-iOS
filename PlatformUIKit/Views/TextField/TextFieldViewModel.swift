//
//  TextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A view model for text field
public class TextFieldViewModel {
    
    // MARK: - Type

    /// The trailing accessory view.
    /// Can potentially support, images, labels and even custom views
    public enum AccessoryContentType: Equatable {
        
        /// Image accessory view
        case badgeImageView(BadgeImageViewModel)
        
        /// Label accessory view
        case badgeLabel(BadgeViewModel)
        
        /// Empty accessory view
        case empty
    }
    
    public enum Focus: Equatable {
        public enum OffSource: Equatable {
            case returnTapped
            case endEditing
            case setup
        }
        
        case on
        case off(OffSource)
        
        var isOn: Bool {
            switch self {
            case .on:
                return true
            case .off:
                return false
            }
        }
    }
    
    struct Mode: Equatable {
        
        /// The title text
        let title: String
        
        /// The title color
        let titleColor: Color
        
        /// The border color
        let borderColor: Color
        
        /// The cursor color
        let cursorColor: Color
        
        init(isFocused: Bool, shouldShowHint: Bool, hint: String, title: String) {
            if shouldShowHint && !hint.isEmpty {
                self.title = hint
                borderColor = .destructive
                titleColor = .destructive
                cursorColor = .destructive
            } else {
                self.title = title
                titleColor = .descriptionText
                if isFocused {
                    borderColor = .primaryButton
                    cursorColor = .primaryButton
                } else {
                    borderColor = .mediumBorder
                    cursorColor = .mediumBorder
                }
            }
        }
    }
        
    private typealias LocalizedString = LocalizationConstants.TextField

    // MARK: Properties

    /// The state of the text field
    public var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    /// Should text field gain / drop focus 
    public let focusRelay = BehaviorRelay<Focus>(value: .off(.setup))
    public var focus: Driver<Focus> {
        focusRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The content type of the `UITextField`
    var contentType: Driver<UITextContentType?> {
        contentTypeRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The keyboard type of the `UITextField`
    var keyboardType: Driver<UIKeyboardType> {
        keyboardTypeRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The isSecureTextEntry of the `UITextField`
    var isSecure: Driver<Bool> {
        isSecureRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The color of the content (.mutedText, .textFieldText)
    var textColor: Driver<UIColor> {
        textColorRelay.asDriver()
    }
        
    /// A text to display below the text field in case of an error
    var mode: Driver<Mode> {
        Driver
            .combineLatest(
                focus,
                showHintIfNeededRelay.asDriver(),
                hintRelay.asDriver(),
                titleRelay.asDriver()
            )
            .map { (isOn: $0.0.isOn, shouldShowHint: $0.1, hint: $0.2, title: $0.3) }
            .map {
                Mode(
                    isFocused: $0.isOn,
                    shouldShowHint: $0.shouldShowHint,
                    hint: $0.hint,
                    title: $0.title
                )
            }
            .distinctUntilChanged()
    }

    public let isEnabledRelay = BehaviorRelay<Bool>(value: true)
    var isEnabled: Observable<Bool> {
        isEnabledRelay.asObservable()
    }
    
    /// The placeholder of the text-field
    public let placeholderRelay: BehaviorRelay<NSAttributedString>
    var placeholder: Driver<NSAttributedString> {
        placeholderRelay.asDriver()
    }
    
    var autocapitalizationType: Observable<UITextAutocapitalizationType> {
        autocapitalizationTypeRelay.asObservable()
    }
                
    /// A relay for accessory content type
    let accessoryContentTypeRelay = BehaviorRelay<AccessoryContentType>(value: .empty)
    var accessoryContentType: Observable<AccessoryContentType> {
        accessoryContentTypeRelay
            .distinctUntilChanged()
    }

    /// The original (initial) content of the text field
    public let originalTextRelay = BehaviorRelay<String?>(value: nil)
    var originalText: Observable<String?> {
        originalTextRelay
            .map { $0?.trimmingCharacters(in: .whitespaces) }
            .distinctUntilChanged()
    }
    
    /// Streams events when the accessory is being tapped
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }
    
    /// Streams events when the accessory is being tapped
    public let tapRelay = PublishRelay<Void>()

    /// The content of the text field
    public let textRelay = BehaviorRelay<String>(value: "")
    public var text: Observable<String> {
        textRelay
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .distinctUntilChanged()
    }
        
    let showHintIfNeededRelay = BehaviorRelay(value: false)
    
    let titleFont = UIFont.main(.medium, 14)
    let textFont = UIFont.main(.medium, 16)
    let titleRelay: BehaviorRelay<String>

    /// Used for equality
    private var internalText: String?
    private let autocapitalizationTypeRelay: BehaviorRelay<UITextAutocapitalizationType>
    private let keyboardTypeRelay: BehaviorRelay<UIKeyboardType>
    private let contentTypeRelay: BehaviorRelay<UITextContentType?>
    private let isSecureRelay = BehaviorRelay(value: false)
    private let textColorRelay = BehaviorRelay<UIColor>(value: .textFieldText)
    private let hintRelay = BehaviorRelay<String>(value: "")
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    let returnKeyType: UIReturnKeyType
    let validator: TextValidating
    let formatter: TextFormatting
    let textMatcher: TextMatchValidatorAPI?
    let type: TextFieldType
    let accessibility: Accessibility
    let messageRecorder: MessageRecording
    
    // MARK: - Setup
    
    public init(with type: TextFieldType,
                accessibilitySuffix: String? = nil,
                returnKeyType: UIReturnKeyType = .done,
                validator: TextValidating,
                formatter: TextFormatting = TextFormatterFactory.alwaysCorrect,
                textMatcher: TextMatchValidatorAPI? = nil,
                messageRecorder: MessageRecording) {
        self.messageRecorder = messageRecorder
        self.formatter = formatter
        self.validator = validator
        self.textMatcher = textMatcher
        self.type = type
        
        let placeholder = NSAttributedString(
            string: type.placeholder,
            attributes: [
                .foregroundColor: UIColor.textFieldPlaceholder,
                .font: textFont
            ]
        )
        
        autocapitalizationTypeRelay = BehaviorRelay(value: type.autocapitalizationType)
        placeholderRelay = BehaviorRelay(value: placeholder)
        titleRelay = BehaviorRelay(value: type.title)
        contentTypeRelay = BehaviorRelay(value: type.contentType)
        keyboardTypeRelay = BehaviorRelay(value: type.keyboardType)
        isSecureRelay.accept(type.isSecure)
        
        if let suffix = accessibilitySuffix {
            accessibility = type.accessibility.with(idSuffix: ".\(suffix)")
        } else {
            accessibility = type.accessibility
        }
        
        self.returnKeyType = returnKeyType

        originalText
            .compactMap { $0 }
            .bindAndCatch(to: textRelay)
            .disposed(by: disposeBag)

        text
            .bindAndCatch(to: validator.valueRelay)
            .disposed(by: disposeBag)

        text
            .subscribe(onNext: { [weak self] text in
                // we update the changes of the text to our internalText property
                // for equality purposes
                self?.internalText = text
            })
            .disposed(by: disposeBag)

        let matchState: Observable<TextValidationState>
        if let textMatcher = textMatcher {
            matchState = textMatcher.validationState
        } else {
            matchState = .just(.valid)
        }
                
        Observable
            .combineLatest(
                matchState,
                validator.validationState,
                text.asObservable()
            )
            .map { matchState, validationState, text in
                State(
                    matchState: matchState,
                    validationState: validationState,
                    text: text
                )
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
        
        self.state
            .map { $0.hint ?? "" }
            .bindAndCatch(to: hintRelay)
            .disposed(by: disposeBag)
    }
    
    public func set(next: TextFieldViewModel) {
        focusRelay
            .filter { $0 == .off(.returnTapped) }
            .map { _ in .on }
            .bindAndCatch(to: next.focusRelay)
            .disposed(by: disposeBag)
    }
    
    func textFieldDidEndEditing() {
        focusRelay.accept(.off(.endEditing))
        showHintIfNeededRelay.accept(true)
    }
    
    func textFieldShouldReturn() -> Bool {
        focusRelay.accept(.off(.returnTapped))
        return true
    }
    
    func textFieldShouldBeginEditing() -> Bool {
        focusRelay.accept(.on)
        return true
    }
    
    /// Should be called upon editing the text field
    func textFieldEdited(with value: String) {
        messageRecorder.record("Text field \(type.debugDescription) edited")
        textRelay.accept(value)
        showHintIfNeededRelay.accept(type.showsHintWhileTyping)
    }
    
    func editIfNecessary(_ text: String, operation: TextInputOperation) -> TextFormattingSource {
        let processResult = formatter.format(text, operation: operation)
        switch processResult {
        case .formatted(to: let processedText), .original(text: let processedText):
            textFieldEdited(with: processedText)
        }
        return processResult
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
        case mismatch(reason: String?)
        
        /// Invalid state - validation is not passing.
        case invalid(reason: String?)
    
        var hint: String? {
            switch self {
            case .invalid(reason: let reason), .mismatch(reason: let reason):
                return reason
            default:
                return nil
            }
        }
        
        public var isEmpty: Bool {
            switch self {
            case .empty:
                return true
            default:
                return false
            }
        }

        var isInvalid: Bool {
            switch self {
            case .invalid:
                return true
            default:
                return false
            }
        }
        
        var isMismatch: Bool {
            switch self {
            case .mismatch:
                return true
            default:
                return false
            }
        }
        
        /// Returns the text value if there is a valid value
        public var value: String? {
            switch self {
            case .valid(value: let value):
                return value
            default:
                return nil
            }
        }
                
        /// Returns whether or not the currenty entry is valid
        public var isValid: Bool {
            switch self {
            case .valid:
                return true
            default:
                return false
            }
        }
        
        /// Reducer for possible validation states
        init(matchState: TextValidationState, validationState: TextValidationState, text: String) {
            guard !text.isEmpty else {
                self = .empty
                return
            }
            switch (matchState, validationState, text) {
            case (.valid, .valid, let text):
                self = .valid(value: text)
            case (.invalid(reason: let reason), _, text):
                self = .mismatch(reason: reason)
            case (_, .invalid(reason: let reason), _):
                self = .invalid(reason: reason)
            default:
                self = .invalid(reason: nil)
            }
        }
    }
}

extension TextFieldViewModel: Equatable {
    public static func == (lhs: TextFieldViewModel, rhs: TextFieldViewModel) -> Bool {
        lhs.internalText == rhs.internalText
    }
}

// MARK: - Equatable (Lossy - only the state, without associated values)

extension TextFieldViewModel.State: Equatable {
    public static func == (lhs: TextFieldViewModel.State,
                           rhs: TextFieldViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid),
             (.mismatch, .mismatch),
             (.invalid, .invalid),
             (.empty, .empty):
            return true
        default:
            return false
        }
    }
}
