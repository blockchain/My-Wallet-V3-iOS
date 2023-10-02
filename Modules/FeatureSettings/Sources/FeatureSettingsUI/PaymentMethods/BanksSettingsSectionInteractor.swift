// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DIKit
import FeatureProductsDomain
import FeatureSettingsDomain
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class BanksSettingsSectionInteractor {

    typealias State = ValueCalculationState<[Beneficiary]>
    var app: AppProtocol
    var state: Observable<State> {
        _ = setup
        return stateRelay
            .observe(on: MainScheduler.instance)
            .asObservable()
    }

    let addPaymentMethodInteractors: [AddPaymentMethodInteractor]

    private lazy var setup: Void =
    Observable.combineLatest(beneficiaries, tradingAccountEnabled)
        .map { beneficiaries, tradingAccountEnabled in
            guard tradingAccountEnabled == true else {
                return .invalid(.empty)
            }
            return .value(beneficiaries)
        }
        .startWith(.calculating)
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()

    private var tradingAccountEnabled: Observable<Bool> {
        app.publisher(for: blockchain.app.is.DeFi.only, as: Bool.self)
            .replaceError(with: true)
            .map(\.not)
            .asObservable()
    }

    private var beneficiaries: Observable<[Beneficiary]> {
        beneficiariesService.beneficiaries
            .asObservable()
            .catchAndReturn([])
    }

    private let beneficiariesService: BeneficiariesServiceAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let tierLimitsProvider: TierLimitsProviding

    // MARK: - Setup

    init(
        beneficiariesService: BeneficiariesServiceAPI = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        tierLimitsProvider: TierLimitsProviding,
        app: AppProtocol = resolve()
    ) {
        self.beneficiariesService = beneficiariesService
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProvider = tierLimitsProvider
        self.app = app
        self.addPaymentMethodInteractors = enabledCurrenciesService.allEnabledFiatCurrencies
            .map {
                AddPaymentMethodInteractor(
                    paymentMethod: .bank($0),
                    addNewInteractor: AddBankInteractor(
                        beneficiariesService: beneficiariesService,
                        fiatCurrency: $0
                    ),
                    tiersLimitsProvider: tierLimitsProvider
                )
            }
    }

    func refresh() {
        beneficiariesService.invalidate()
    }
}
