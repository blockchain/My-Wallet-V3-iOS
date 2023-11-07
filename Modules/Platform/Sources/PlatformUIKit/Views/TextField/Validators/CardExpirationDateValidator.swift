// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxRelay
import RxSwift
import ToolKit

public final class CardExpirationDateValidator: TextValidating {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.TextField.Gesture

    // MARK: - Properties

    public let valueRelay = BehaviorRelay<String>(value: "")

    public var validationState: Observable<TextValidationState> {
        regexValidator.validationState
            .flatMap(weak: self) { (self, state) in
                switch state {
                case .valid:
                    self.dateValidationState.asObservable()
                case .invalid:
                    .just(state)
                case .conceivable, .blocked:
                    unimplemented("Conceivable is not accounted for with card expiration")
                }
            }
    }

    private var date: Single<Date?> {
        valueRelay
            .take(1)
            .map(weak: self) { (self, rawDate) -> String in
                self.correctYear(rawDate: rawDate)
            }
            .map(weak: self) { (self, rawDate) in
                self.dateFormatter.date(from: rawDate)
            }
            .asSingle()
    }

    private var dateValidationState: Single<TextValidationState> {
        date
            .map { date in
                guard let date else { return false }
                return date > Date()
            }
            .map { $0 ? .valid : .invalid(reason: LocalizedString.invalidExpirationDate) }
    }

    private let dateFormatter = DateFormatter.cardExpirationDate
    private let regexValidator: RegexTextValidator
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init() {
        self.regexValidator = RegexTextValidator(
            regex: .cardExpirationDate,
            invalidReason: LocalizedString.invalidExpirationDate
        )

        valueRelay
            .bindAndCatch(to: regexValidator.valueRelay)
            .disposed(by: disposeBag)
    }

    private func correctYear(rawDate: String) -> String {
        let components = rawDate.split(separator: "/")
        return "\(components[0])/20\(components[1])"
    }
}
