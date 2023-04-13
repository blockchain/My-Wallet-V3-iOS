// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class InterestAccountService: InterestAccountServiceAPI {

    // MARK: - Private Properties

    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let priceService: PriceServiceAPI
    private let interestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI
    private let interestAccountLimitsRepository: InterestAccountLimitsRepositoryAPI
    private let interestAccountEligibilityRepository: InterestAccountEligibilityRepositoryAPI
    private let interestAccountRateRepository: InterestAccountRateRepositoryAPI
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Setup

    init(
        interestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI = resolve(),
        interestAccountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve(),
        interestAccountEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve(),
        interestAccountRateRepository: InterestAccountRateRepositoryAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve()
    ) {
        self.interestAccountRateRepository = interestAccountRateRepository
        self.interestAccountEligibilityRepository = interestAccountEligibilityRepository
        self.interestAccountLimitsRepository = interestAccountLimitsRepository
        self.interestAccountBalanceRepository = interestAccountBalanceRepository
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiersService = kycTiersService
    }

    // MARK: - InterestAccountServiceAPI

    func fetchInterestAccountLimitsForCryptoCurrency(
        _ currency: CryptoCurrency
    ) -> Single<InterestAccountLimits?> {
        fiatCurrencyService
            .displayCurrency
            .flatMap { [interestAccountLimitsRepository] fiatCurrency in
                interestAccountLimitsRepository
                    .fetchInterestAccountLimitsForAllAssets(fiatCurrency)
            }
            .map { $0.filter { $0.cryptoCurrency == currency } }
            .map(\.first)
            .asSingle()
    }

    func fetchInterestAccountDetailsForCryptoCurrency(
        _ currency: CryptoCurrency
    ) -> Single<ValueCalculationState<InterestAccountBalanceDetails>> {
        details(for: currency)
    }

    func details(for currency: CryptoCurrency) -> Single<ValueCalculationState<InterestAccountBalanceDetails>> {
        interestAccountsBalance
            .map { balances in
                switch balances[currency] {
                case .none:
                    return .invalid(.empty)
                case .some(let details):
                    return .value(details)
                }
            }
            .asSingle()
    }

    // MARK: - InterestAccountOverviewAPI

    func invalidateInterestAccountBalances() {
        fiatCurrencyService
            .displayCurrency
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [interestAccountBalanceRepository] fiatCurrency in
                interestAccountBalanceRepository
                    .invalidateAccountBalanceCacheWithKey(fiatCurrency)
            })
            .store(in: &cancellables)
    }

    func balance(for currency: CryptoCurrency) -> AnyPublisher<CustodialAccountBalanceState, Never> {
        interestAccountsBalance
            .map(CustodialAccountBalanceStates.init)
            .map(\.[currency.currencyType])
            .eraseToAnyPublisher()
    }

    func rate(for currency: CryptoCurrency) -> Single<Double> {
        interestAccountRateRepository
            .fetchInterestAccountRateForCryptoCurrency(currency)
            .map(\.rate)
            .asSingle()
    }

    private var interestAccountsBalance: AnyPublisher<InterestAccountBalances, Never> {
        let isVerifiedApproved = kycTiersService.tiers
            .map(\.isVerifiedApproved)
            .eraseError()
        let displayCurrency = fiatCurrencyService
            .displayCurrency
            .eraseError()
        return isVerifiedApproved
            .zip(displayCurrency)
            .flatMap { [interestAccountBalanceRepository] isVerifiedApproved, displayCurrency
                -> AnyPublisher<InterestAccountBalances, Error> in
                guard isVerifiedApproved else {
                    return .just(.empty)
                }
                return interestAccountBalanceRepository
                    .fetchInterestAccountsBalance(fiatCurrency: displayCurrency)
                    .eraseError()
            }
            .replaceError(with: .empty)
            .eraseToAnyPublisher()
    }
}
