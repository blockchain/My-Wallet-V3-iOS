//
//  MockWalletService.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class MockWalletService: WalletService {

    var mockCreatePinResponse: Single<PinStoreResponse>?
    var mockWalletOptions: WalletOptions?

    override var walletOptions: Single<WalletOptions> {
        if let mockWalletOptions = mockWalletOptions {
            return Single.just(mockWalletOptions)
        }
        return Single.just(WalletOptions(json: ["maintenance": false]))
    }

    override func createPin(_ pinPayload: PinPayload) -> Single<PinStoreResponse> {
        guard let mock = mockCreatePinResponse else {
            return Single.just(PinStoreResponse(response: [:]))
        }
        return mock
    }
}
