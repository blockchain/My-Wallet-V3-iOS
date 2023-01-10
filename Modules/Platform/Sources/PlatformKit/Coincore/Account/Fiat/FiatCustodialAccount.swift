// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Localization
import MoneyKit
import RxSwift
import ToolKit

final class FiatCustodialAccount: FiatAccount {

    private(set) lazy var identifier: AnyHashable = "FiatCustodialAccount.\(fiatCurrency.code)"
    let isDefault: Bool = true
    let label: String
    let fiatCurrency: FiatCurrency
    let accountType: AccountType = .trading

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }

    var disabledReason: AnyPublisher<InterestAccountIneligibilityReason, Error> {
        interestEligibilityRepository
            .fetchInterestAccountEligibilityForCurrencyCode(currencyType)
            .map(\.ineligibilityReason)
            .eraseError()
    }

    var activity: AnyPublisher<[ActivityItemEvent], Error> {
        activityFetcher
            .activity(fiatCurrency: fiatCurrency)
            .map { items in
                items.map(ActivityItemEvent.fiat)
            }
            .replaceError(with: [])
            .eraseError()
            .eraseToAnyPublisher()
    }

    var canWithdrawFunds: Single<Bool> {
        // TODO: Fetch transaction history and filer
        // for transactions that are `withdrawals` and have a
        // transactionState of `.pending`.
        // If there are no items, the user can withdraw funds.
        unimplemented()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.pending)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.available)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    var mainBalanceToDisplay: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.mainBalanceToDisplay)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    private let interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI
    private let activityFetcher: OrdersActivityServiceAPI
    private let balanceService: TradingBalanceServiceAPI
    private let priceService: PriceServiceAPI
    private let paymentMethodService: PaymentMethodTypesServiceAPI
    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: currencyType)
    }
    private let app: AppProtocol

    init(
        fiatCurrency: FiatCurrency,
        interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve(),
        activityFetcher: OrdersActivityServiceAPI = resolve(),
        balanceService: TradingBalanceServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        paymentMethodService: PaymentMethodTypesServiceAPI = resolve(),
        app: AppProtocol = DIKit.resolve()
    ) {
        self.label = fiatCurrency.defaultWalletName
        self.interestEligibilityRepository = interestEligibilityRepository
        self.fiatCurrency = fiatCurrency
        self.activityFetcher = activityFetcher
        self.paymentMethodService = paymentMethodService
        self.balanceService = balanceService
        self.priceService = priceService
        self.app = app
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .viewActivity:
            return app.publisher(for: blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self)
                .mapError()
                .receive(on: DispatchQueue.main)
                .map { fetched in
                    guard let isEnabled = fetched.value else {
                        return true
                    }
                    // if we're on superapp disable this for Fiat accounts
                    return !isEnabled
                }
                .first()
                .eraseToAnyPublisher()
        case .buy,
             .send,
             .sell,
             .swap,
             .sign,
             .receive,
             .interestTransfer,
             .interestWithdraw,
             .stakingDeposit:
            return .just(false)
        case .deposit:
            return paymentMethodService
                .canTransactWithBankPaymentMethods(fiatCurrency: fiatCurrency)
                .asPublisher()
                .eraseToAnyPublisher()
        case .withdraw:
            // TODO: Account for OB
            let hasActionableBalance = actionableBalance
                .map(\.isPositive)
            let canTransactWithBanks = paymentMethodService
                .canTransactWithBankPaymentMethods(fiatCurrency: fiatCurrency)
                .asPublisher()
            return canTransactWithBanks.zip(hasActionableBalance)
                .map { canTransact, hasBalance in
                    canTransact && hasBalance
                }
                .eraseToAnyPublisher()
        }
    }

    func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    func invalidateAccountBalance() {
        balanceService
            .invalidateTradingAccountBalances()
    }
}
