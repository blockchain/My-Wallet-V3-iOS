// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

struct AddPaymentMethodLocalizedStrings {

    private typealias AccessibilityID = Accessibility.Identifier.Settings

    private static var card: AddPaymentMethodLocalizedStrings {
        typealias LocalizedString = LocalizationConstants.Settings.Card
        return AddPaymentMethodLocalizedStrings(
            kycDisabled: LocalizedString.unverified,
            notAbleToAddNew: LocalizedString.maximum,
            cta: LocalizedString.add,
            accessibilityId: "\(AccessibilityID.AddPaymentMethodCell.disclaimer).card"
        )
    }

    private static func bank(for fiatCurrency: FiatCurrency) -> AddPaymentMethodLocalizedStrings {
        typealias LocalizedString = LocalizationConstants.Settings.Bank
        return AddPaymentMethodLocalizedStrings(
            kycDisabled: LocalizedString.unverified,
            notAbleToAddNew: LocalizedString.maximum,
            cta: "\(LocalizedString.addPrefix) \(fiatCurrency.displayCode) \(LocalizedString.addSuffix)",
            accessibilityId: "\(AccessibilityID.AddPaymentMethodCell.disclaimer).bank.\(fiatCurrency.displayCode)"
        )
    }

    let kycDisabled: String
    let notAbleToAddNew: String
    let cta: String
    let accessibilityId: String
}

extension AddPaymentMethodLocalizedStrings {
    init(_ paymentMethod: AddPaymentMethodInteractor.PaymentMethod) {
        switch paymentMethod {
        case .bank(let currency):
            self = .bank(for: currency)
        case .card:
            self = .card
        }
    }
}

final class AddPaymentMethodLabelContentInteractor: LabelContentInteracting {

    // MARK: - Types

    typealias InteractionState = LabelContent.State.Interaction
    typealias Descriptors = LabelContent.Value.Presentation.Content.Descriptors

    // MARK: - Properties

    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    let descriptorRelay = BehaviorRelay<Descriptors>(value: .settings)
    var descriptorObservable: Observable<Descriptors> {
        descriptorRelay.asObservable()
    }

    // MARK: - Private Properties

    private let localizedStrings: AddPaymentMethodLocalizedStrings
    private let interactor: AddPaymentMethodInteractor
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: AddPaymentMethodInteractor, localizedStrings: AddPaymentMethodLocalizedStrings) {
        self.interactor = interactor
        self.localizedStrings = localizedStrings
        setup()
    }

    private func setup() {
        let localizedStrings = localizedStrings
        interactor.isEnabledForUser
            .map { isEnabledForUser in
                if isEnabledForUser {
                    .settings
                } else {
                    .disclaimer(accessibilityId: localizedStrings.accessibilityId)
                }
            }
            .bindAndCatch(to: descriptorRelay)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                interactor.isAbleToAddNew,
                interactor.isKYCVerified
            )
            .map { isAbleToAddNew, isKYCVerified in
                guard isKYCVerified else { return localizedStrings.kycDisabled }
                guard isAbleToAddNew else { return localizedStrings.notAbleToAddNew }
                return localizedStrings.cta
            }
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
