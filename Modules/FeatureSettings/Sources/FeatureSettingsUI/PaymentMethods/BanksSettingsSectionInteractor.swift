// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsDomain
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class BanksSettingsSectionInteractor {

    typealias State = ValueCalculationState<[Beneficiary]>

    var state: Observable<State> {
        _ = setup
        return stateRelay
            .observe(on: MainScheduler.instance)
            .asObservable()
    }

    let addPaymentMethodInteractors: [AddPaymentMethodInteractor]

    private lazy var setup: Void = beneficiaries
        .map { .value($0) }
        .startWith(.calculating)
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()

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
        tierLimitsProvider: TierLimitsProviding
    ) {
        self.beneficiariesService = beneficiariesService
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProvider = tierLimitsProvider

        addPaymentMethodInteractors = enabledCurrenciesService.allEnabledFiatCurrencies
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
