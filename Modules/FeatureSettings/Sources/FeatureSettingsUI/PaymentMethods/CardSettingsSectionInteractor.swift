// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureCardPaymentDomain
import FeatureProductsDomain
import FeatureSettingsDomain
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class CardSettingsSectionInteractor {

    typealias State = ValueCalculationState<[CardData]>
    var app: AppProtocol
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
        Observable
            .combineLatest(cards, externalBrokerageActive, tradingAccountEnabled)
            .map { values, externalBrokerageActive, tradingAccountEnabled -> State in
                guard externalBrokerageActive == false else {
                    return .invalid(.empty)
                }

                guard tradingAccountEnabled == true else {
                    return .invalid(.empty)
                }

            return .value(values)
            }
    }

    private var tradingAccountEnabled: Observable<Bool> {
        app.publisher(for: blockchain.app.is.DeFi.only, as: Bool.self)
            .replaceError(with: true)
            .map(\.not)
            .asObservable()
    }

    private var externalBrokerageActive: Observable<Bool> {
        app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
                    .replaceError(with: false)
                    .asObservable()
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
        tierLimitsProvider: TierLimitsProviding,
        app: AppProtocol
    ) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProvider = tierLimitsProvider
        self.app = app

        self.addPaymentMethodInteractor = AddPaymentMethodInteractor(
            paymentMethod: .card,
            addNewInteractor: AddCardInteractor(
                paymentMethodTypesService: paymentMethodTypesService
            ),
            tiersLimitsProvider: tierLimitsProvider
        )
    }
}
