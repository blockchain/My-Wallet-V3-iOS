// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public protocol AssetBalanceInfoRepositoryAPI {

    func cryptoCustodial() -> StreamOf<[AssetBalanceInfo], Never>
    func fiat() -> StreamOf<[AssetBalanceInfo], Never>
    func cryptoNonCustodial() -> StreamOf<[AssetBalanceInfo], Never>
}
