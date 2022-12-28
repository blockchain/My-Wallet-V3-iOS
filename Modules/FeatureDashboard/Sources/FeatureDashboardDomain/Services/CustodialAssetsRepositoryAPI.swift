// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol CustodialAssetsRepositoryAPI {
    func assetsInfo() -> AnyPublisher<[AssetBalanceInfo], Error>
}
