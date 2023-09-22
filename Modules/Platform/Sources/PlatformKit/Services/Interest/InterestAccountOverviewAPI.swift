//
//  InterestAccountOverviewAPI.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import Foundation
import MoneyKit
import RxSwift

public protocol InterestAccountOverviewAPI {
    func invalidateInterestAccountBalances()
    func rate(for currency: CryptoCurrency) -> Single<Double>
    func balance(
        for currency: CryptoCurrency
    ) -> AnyPublisher<CustodialAccountBalanceState, Never>
}
