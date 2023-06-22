// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import Localization
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class CardNumberValidator: TextValidating, CardTypeSource {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.TextField.Gesture

    // MARK: - Exposed Properties

    /// An observable that streams the card type
    public var validationState: Observable<TextValidationState> {
        validationStateRelay
            .asObservable()
    }

    /// An observable that streams the card type
    public var cardType: Observable<CardType> {
        cardTypeRelay
            .asObservable()
    }

    public var ux: Observable<UX.Error?> {
        uxRelay
            .asObservable()
    }

    public let valueRelay = BehaviorRelay<String>(value: "")
    public let supportedCardTypesRelay = BehaviorRelay<Set<CardType>>(value: [])

    // MARK: - Private Properties

    private let cardTypeRelay = BehaviorRelay<CardType>(value: .unknown)
    private let luhnValidator = LuhnNumberValidator()
    private let cardSuccessRateService: CardSuccessRateServiceAPI
    private let uxRelay = BehaviorRelay<UX.Error?>(value: nil)
    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let disposeBag = DisposeBag()

    private enum CardSuccessRateStatus {
        // The card prefix has the best chance of success
        case best
        // The card prefix is permissable but has a chance of failure
        case unblocked(UX.Error?)
        // The card prefix belongs to a card that will not work
        case blocked(UX.Error?)
        // UX model, if there is one.
        var ux: UX.Error? {
            switch self {
            case .unblocked(let ux),
                    .blocked(let ux):
                return ux
            case .best:
                return nil
            }
        }
    }

    // MARK: - Setup

    // swiftlint:disable cyclomatic_complexity
    public init(
        supportedCardTypes: Set<CardType> = [.visa],
        cardSuccessRateService: CardSuccessRateServiceAPI = resolve()
    ) {
        self.cardSuccessRateService = cardSuccessRateService
        supportedCardTypesRelay.accept(supportedCardTypes)

        valueRelay
            .map { .determineType(from: $0) }
            .bindAndCatch(to: cardTypeRelay)
            .disposed(by: disposeBag)

        let cardSuccessRateStatus = valueRelay
            .map { $0.replacingOccurrences(of: " ", with: "") }
            .flatMap(weak: self) { (self, input) -> Observable<CardSuccessRateStatus> in
                guard input.count >= 8 else { return .just(.best) }
                let prefix = String(input.prefix(8))
                return self.fetchCardSuccessRateStatusForEntry(prefix)
            }

        cardSuccessRateStatus
            .compactMap(\.ux)
            .bindAndCatch(to: uxRelay)
            .disposed(by: disposeBag)

        let inputData = Observable
            .zip(cardSuccessRateStatus, valueRelay, cardType)

        Observable
            .combineLatest(
                inputData,
                supportedCardTypesRelay
            )
            .map(weak: self) { (self, payload) -> TextValidationState in
                let ((successRate, value, cardType), supportedCardTypes) = payload
                let cardTypeSupported = supportedCardTypes.contains(cardType) && cardType.isKnown
                let isCardNumberValid = self.isValid(value)

                switch successRate {
                case .best:
                    switch (cardTypeSupported, isCardNumberValid) {
                    case (true, true):
                        return .valid
                    case (false, _):
                        return .invalid(reason: LocalizedString.unsupportedCardType)
                    case (true, false):
                        return .invalid(reason: LocalizedString.invalidCardNumber)
                    }
                case .unblocked(let ux):
                    let title = ux?.title
                    switch (cardTypeSupported, isCardNumberValid) {
                    case (true, true):
                        return .conceivable(reason: title ?? LocalizedString.thisCardOftenDeclines)
                    case (false, _):
                        return .invalid(reason: LocalizedString.unsupportedCardType)
                    case (true, false):
                        return .invalid(reason: LocalizedString.invalidCardNumber)
                    }
                case .blocked(let ux):
                    let title = ux?.title
                    switch (cardTypeSupported, isCardNumberValid) {
                    case (true, true):
                        return .blocked(reason: title ?? LocalizedString.buyingCryptoNotSupported)
                    case (false, _):
                        return .invalid(reason: LocalizedString.unsupportedCardType)
                    case (true, false):
                        return .invalid(reason: LocalizedString.invalidCardNumber)
                    }
                }
            }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }

    func supports(cardType: CardType) -> Bool {
        supportedCardTypesRelay.value.contains(cardType)
    }

    private func fetchCardSuccessRateStatusForEntry(
        _ binNumber: String
    ) -> Observable<CardSuccessRateStatus> {
        cardSuccessRateService
            .getCardSuccessRate(binNumber: binNumber)
            .map { successRateData -> CardSuccessRateStatus in
                let blockCard = successRateData.block
                let ux = successRateData.ux
                switch (blockCard, ux) {
                case (true, .some(let ux)):
                    return .blocked(UX.Error(nabu: ux))
                case (false, .some(let ux)):
                    return .unblocked(UX.Error(nabu: ux))
                case (false, .none):
                    return .best
                default:
                    return .best
                }
            }
            .asObservable()
    }

    private func isValid(_ number: String) -> Bool {
        var number = number
        number.removeAll { $0 == " " }

        guard luhnValidator.validate(number: number) else {
            return false
        }
        for type in CardType.all {
            let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
            if predicate.evaluate(with: number) {
                return true
            }
        }
        return false
    }
}
