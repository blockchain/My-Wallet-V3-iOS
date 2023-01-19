// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import ToolKit

public protocol AssetBalanceInfoRepositoryAPI {

    func cryptoCustodial(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never>
    func fiat(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never>
    func cryptoNonCustodial(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never>
}
