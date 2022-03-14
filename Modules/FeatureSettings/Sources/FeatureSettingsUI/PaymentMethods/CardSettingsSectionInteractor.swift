// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardsDomain
import FeatureSettingsDomain
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class CardSettingsSectionInteractor {

    typealias State = ValueCalculationState<[CardData]>

    var state: Observable<State> {
        _ = setup
        return stateRelay
            .asObservable()
    }

    let addPaymentMethodInteractor: AddPaymentMethodInteractor

    private lazy var setup: Void = cardsState
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()

    private var cardsState: Observable<State> {
        cards.map { values -> State in
            .value(values)
        }
    }

    private var cards: Observable<[CardData]> {
        paymentMethodTypesService.cards
            .map { $0.filter { $0.state == .active || $0.state == .expired } }
            .catchAndReturn([])
    }

    // MARK: - Injected

    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let tierLimitsProvider: TierLimitsProviding

    // MARK: - Setup

    init(
        paymentMethodTypesService: PaymentMethodTypesServiceAPI,
        tierLimitsProvider: TierLimitsProviding
    ) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProvider = tierLimitsProvider

        addPaymentMethodInteractor = AddPaymentMethodInteractor(
            paymentMethod: .card,
            addNewInteractor: AddCardInteractor(
                paymentMethodTypesService: paymentMethodTypesService
            ),
            tiersLimitsProvider: tierLimitsProvider
        )
    }
}
