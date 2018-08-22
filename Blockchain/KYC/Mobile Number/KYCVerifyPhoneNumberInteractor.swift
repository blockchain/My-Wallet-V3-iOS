//
//  KYCVerifyPhoneNumberInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PhoneNumberKit
import RxSwift

class KYCVerifyPhoneNumberInteractor {

    private let phoneNumberKit = PhoneNumberKit()

    /// Starts the mobile verification process. This should be called when the
    /// user wishes to update their mobile phone number during the KYC flow.
    ///
    /// - Parameter number: the phone number
    /// - Returns: a Completable which completes if the phone number is success
    ///            was successfully updated, otherwise, it will emit an error.
    func startVerification(number: String) -> Completable {
        return KYCAuthenticationService.shared.getKycSessionToken().flatMapCompletable { [unowned self] token in
            do {
                let phoneNumber = try self.phoneNumberKit.parse(number)
                let formattedPhoneNumber = self.phoneNumberKit.format(phoneNumber, toType: .e164)
                let headers = [HttpHeaderField.authorization: token.token]
                let payload = KYCUpdateMobileRequest(mobile: formattedPhoneNumber)
                return KYCNetworkRequest.request(
                    put: .updateMobileNumber,
                    parameters: payload,
                    headers: headers
                )
            } catch {
                return Completable.error(error)
            }
        }
    }

    func verify(
        number: String,
        userId: String,
        code: String,
        success: @escaping KYCNetworkRequest.TaskSuccess,
        failure: @escaping KYCNetworkRequest.TaskFailure
    ) {
        let paramaters = [
            "value": number,
            "userId": userId,
            "type": "MOBILE",
            "code": code
        ]
        KYCNetworkRequest(
            post: .verifications,
            parameters: paramaters,
            headers: [:], // TODO: pass in authorization token
            taskSuccess: success,
            taskFailure: failure
        )
    }
}
