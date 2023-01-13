// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MoneyKit

public protocol EarnRepositoryAPI {

    var product: String { get }

    func balances() -> AnyPublisher<EarnAccounts, Nabu.Error>
    func invalidateBalances()

    func eligibility() -> AnyPublisher<EarnEligibility, Nabu.Error>
    func userRates() -> AnyPublisher<EarnUserRates, Nabu.Error>
    func limits(currency: FiatCurrency) -> AnyPublisher<EarnLimits, Nabu.Error>
    func address(currency: CryptoCurrency) -> AnyPublisher<EarnAddress, Nabu.Error>
    func activity(currency: CryptoCurrency) -> AnyPublisher<[EarnActivity], Nabu.Error>

    func deposit(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error>
    func withdraw(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error>
}
