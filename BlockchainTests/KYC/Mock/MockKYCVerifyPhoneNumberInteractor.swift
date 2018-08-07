//
//  MockKYCVerifyPhoneNumberInteractor.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockKYCVerifyPhoneNumberInteractor: KYCVerifyPhoneNumberInteractor {
    var shouldSucceed = true

    override func startVerification(
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

    override func verify(
        number: String,
        userId: String,
        code: String,
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
