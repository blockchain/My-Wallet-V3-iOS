//
//  MnemonicTextViewViewModel.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/11/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import LocalizationKit

/// A view model for `MnemonicTextViewViewModel`
public struct MnemonicTextViewViewModel {
    
    public enum State: Equatable {
        
        case complete(value: NSAttributedString)
        
        case valid(value: NSAttributedString)
        
        case empty
        
        case invalid(value: NSAttributedString)
        
        init(
            input: String,
            score: MnemonicValidationScore,
            validStyle: Style = .default,
            invalidStyle: Style = .desctructive
        ) {
            switch score {
            case .complete:
                self = .complete(value: .init(
                    input.lowercased(),
                    font: validStyle.font,
                    color: validStyle.color
                    )
                )
            case .incomplete:
                self = .valid(value: .init(
                    input.lowercased(),
                    font: validStyle.font,
                    color: validStyle.color
                    )
                )
            case .invalid(let ranges):
                let attributed: NSMutableAttributedString = .init(
                    input.lowercased(),
                    font: validStyle.font,
                    color: validStyle.color
                )
                ranges.forEach {
                    attributed.addAttributes([
                        .font: invalidStyle.font,
                        .foregroundColor: invalidStyle.color
                        ], range: $0)
                }
                self = .invalid(value: .init(attributedString: attributed))
            case .none:
                self = .empty
            }
        }
        
    }
    
    /// A style for text
    public struct Style {
        public let color: UIColor
        public let font: UIFont
        
        public init(color: UIColor, font: UIFont) {
            self.color = color
            self.font = font
        }
    }
    
    // MARK: Properties

    /// The state of the text field
    public var state: Observable<State> {
        return stateRelay.asObservable()
    }
    
    var borderColor: Driver<UIColor> {
        return borderColorRelay.asDriver()
    }
    
    let accessibility: Accessibility = .init(id: .value(Accessibility.Identifier.MnemonicTextView.recoveryPhrase))
    
    let attributedPlaceholder = NSAttributedString(
        string: LocalizationConstants.TextField.Placeholder.recoveryPhrase,
        attributes: [.font: UIFont.mainMedium(16.0)]
    )
    
    let attributedTextRelay = BehaviorRelay<NSAttributedString>(value: .init(string: ""))
    var attributedText: Driver<NSAttributedString> {
        return attributedTextRelay
        .asDriver()
    }
    
    /// The content of the text field
    let textRelay = BehaviorRelay<String>(value: "")
    var text: Observable<String> {
        return textRelay.asObservable()
    }
    
    /// Each input is formatted according to its nature
    public enum Input {
        /// A regular string
        case text(string: String)
    }
    
    let lineSpacing: CGFloat
    
    private let borderColorRelay = BehaviorRelay<UIColor>(value: .black)
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    private let validator: MnemonicValidating
    private let disposeBag = DisposeBag()
    
    public init(
        validator: MnemonicValidating,
        lineSpacing: CGFloat = 0
    ) {
        self.lineSpacing = lineSpacing
        self.validator = validator
        
        text
            .bind(to: validator.valueRelay)
            .disposed(by: disposeBag)
        
        Observable.zip(validator.valueRelay, validator.score)
            .map { (value, score) -> State in
                return State(input: value, score: score)
        }
        .bind(to: stateRelay)
        .disposed(by: disposeBag)
        
        validator.score.map {
            return $0.tintColor
        }
        .bind(to: borderColorRelay)
        .disposed(by: disposeBag)
        
        stateRelay.map { state -> NSAttributedString in
            switch state {
            case .empty:
                return .init(string: "")
            case .valid(value: let value):
                return value
            case .complete(value: let value):
                return value
            case .invalid(value: let value):
                return value
            }
        }
        .bind(to: attributedTextRelay)
        .disposed(by: disposeBag)
    }
    
    /// Should be called upon editing the text field
    func textViewEdited(with value: String) {
        textRelay.accept(value)
    }
}

extension MnemonicTextViewViewModel.Style {
    static let `default`: MnemonicTextViewViewModel.Style = .init(
        color: .black,
        font: UIFont.mainMedium(16.0)
    )
    
    static let desctructive: MnemonicTextViewViewModel.Style = .init(
        color: .destructive,
        font: UIFont.mainMedium(16.0)
    )
}

extension MnemonicTextViewViewModel.State {
    public static func ==(lhs: MnemonicTextViewViewModel.State, rhs: MnemonicTextViewViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.complete(let left), .complete(value: let right)):
            return left == right
        case (.invalid(let left), .invalid(let right)):
            return left == right
        case (.valid(let left), .valid(value: let right)):
            return left == right
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

extension MnemonicValidationScore {
    var tintColor: UIColor {
        switch self {
        case .complete:
            return .normalPassword
        case .incomplete,
             .none:
            return .mediumBorder
        case .invalid:
            return .destructive
        }
    }
}
