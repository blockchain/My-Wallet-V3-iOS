//
//  KYCVerifyPhoneNumberInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCVerifyPhoneNumberInteractor {

    func verify(
        number: String,
        userId: String,
        success: @escaping KYCNetworkRequest.TaskSuccess,
        failure: @escaping KYCNetworkRequest.TaskFailure
    ) {
        let paramaters = ["mobile": number]
        KYCNetworkRequest(
            put: .updateMobileNumber(userId: userId),
            parameters: paramaters,
            taskSuccess: success,
            taskFailure: failure
        )
    }
}
