// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import ToolKit

public protocol AssetBalanceInfoServiceAPI {
    func getCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never>
    func getFiatAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never>
    func getNonCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never>
}
