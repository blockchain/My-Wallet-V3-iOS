// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import Localization
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A view model that represents a password text field
public final class PasswordTextFieldViewModel: TextFieldViewModel {

    // MARK: - Types

    /// Describes the score of the text field
    /// Handly when passwords / passphrases are involved
    enum Score {
        /// No score is needed
        case hidden

        /// Weak score
        case weak

        /// Normal score
        case normal

        /// Strong score
        case strong

        /// Title that repreents the score
        var title: String {
            switch self {
            case .hidden:
                return ""
            case .weak:
                return LocalizationConstants.TextField.PasswordScore.weak
            case .normal:
                return LocalizationConstants.TextField.PasswordScore.normal
            case .strong:
                return LocalizationConstants.TextField.PasswordScore.strong
            }
        }

        /// Progress moves in the range of [0...1]
        var progress: CGFloat {
            switch self {
            case .hidden:
                return 0
            case .weak:
                return 0.3334
            case .normal:
                return 0.6667
            case .strong:
                return 1
            }
        }

        /// Color that represents the score
        var color: UIColor {
            switch self {
            case .hidden:
                return .clear
            case .weak:
                return .destructive
            case .normal:
                return .normalPassword
            case .strong:
                return .primary
            }
        }

        init(score: PasswordValidationScore) {
            switch score {
            case .none:
                self = .hidden
            case .weak:
                self = .weak
            case .normal:
                self = .normal
            case .strong:
                self = .strong
            }
        }
    }

    // MARK: - Properties

    /// A validating object for passwords
    private let passwordValidator: NewPasswordValidating

    /// The score of the text field content
    var score: Observable<Score> {
        scoreRelay
            .asObservable()
            .distinctUntilChanged()
    }

    private let scoreRelay = BehaviorRelay<Score>(value: .hidden)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        with type: TextFieldType,
        passwordValidator: NewPasswordValidating,
        textMatchValidator: CollectionTextMatchValidator,
        messageRecorder: MessageRecording
    ) {
        self.passwordValidator = passwordValidator
        super.init(with: type, validator: passwordValidator, textMatcher: textMatchValidator, messageRecorder: messageRecorder)
        passwordValidator.score
            .map { Score(score: $0) }
            .bindAndCatch(to: scoreRelay)
            .disposed(by: disposeBag)

        // Bind score title to score label
        scoreRelay
            .map {
                let viewModel = BadgeViewModel(
                    font: .main(.medium, 14),
                    cornerRadius: 8,
                    accessibility: .none
                )
                viewModel.textRelay.accept($0.title)
                viewModel.contentColorRelay.accept($0.color)
                return viewModel
            }
            .map { .badgeLabel($0) }
            .bindAndCatch(to: accessoryContentTypeRelay)
            .disposed(by: disposeBag)
    }
}
