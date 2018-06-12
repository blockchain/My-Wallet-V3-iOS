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
    var mockValidatePinResponse: Single<GetPinResponse>?

    override func validatePin(_ pinPayload: PinPayload) -> Single<GetPinResponse> {
        guard let mock = mockValidatePinResponse else {
            return Single.just(GetPinResponse(response: [:]))
        }
        return mock
    }
}
