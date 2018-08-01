//
//  MockKYCEnterPhoneNumberInteractor.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockKYCEnterPhoneNumberInteractor: KYCEnterPhoneNumberInteractor {
    var shouldSucceed = true

    override func verify(
        number: String,
        userId: String,
        success: @escaping KYCNetworkRequest.TaskSuccess,
        failure: @escaping KYCNetworkRequest.TaskFailure
    ) {
        if shouldSucceed {
            success(Data())
        } else {
            failure(HTTPRequestServerError.badResponse)
        }
    }
}
