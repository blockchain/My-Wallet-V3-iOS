//
//  MockPinInteractor.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class MockPinInteractor: PinInteractor {
    var mockValidatePinResponse: Single<PinStoreResponse>?
    var mockCreatePinResponse: Single<PinStoreResponse>?

    private var defaultMockPinStoreResponse: Single<PinStoreResponse> {
        return Single.just(PinStoreResponse(response: [:]))
    }

    override func createPin(_ pinPayload: PinPayload) -> Single<PinStoreResponse> {
        guard let mock = mockCreatePinResponse else {
            return super.createPin(pinPayload)
        }
        return mock
    }

    override func validatePin(_ pinPayload: PinPayload) -> Single<PinStoreResponse> {
        guard let mock = mockValidatePinResponse else {
            return defaultMockPinStoreResponse
        }
        return mock
    }
}
