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
    private let authenticationService: NabuAuthenticationService
    private let wallet: Wallet
    private let walletService: WalletService

    init(
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        wallet: Wallet = WalletManager.shared.wallet,
        walletService: WalletService = WalletService.shared
    ) {
        self.authenticationService = authenticationService
        self.wallet = wallet
        self.walletService = walletService
    }

    /// Starts the mobile verification process. This should be called when the
    /// user wishes to update their mobile phone number during the KYC flow.
    ///
    /// - Parameter number: the phone number
    /// - Returns: a Completable which completes if the phone number is success
    ///            was successfully updated, otherwise, it will emit an error.
    func startVerification(number: String) -> Completable {
        do {
            let phoneNumber = try self.phoneNumberKit.parse(number)
            let formattedPhoneNumber = self.phoneNumberKit.format(phoneNumber, toType: .e164)
            return wallet.changeMobileNumber(formattedPhoneNumber)
        } catch {
            return Completable.error(error)
        }
    }

    /// Verifies the mobile number entered by the user during the KYC flow.
    ///
    /// Upon successfully validating a user's mobile number, which is saved on the wallet
    /// settings, this function will then obtain a JWT for the user's wallet which is
    /// then sent to Nabu.
    ///
    /// - Parameters:
    ///   - code: the code sent to the mobile number
    /// - Returns: a Completable which completes if the verification process succeeds
    ///            otherwise, it will emit an error.
    func verifyNumber(with code: String) -> Completable {
        return wallet.verifyMobileNumber(
            code
        ).andThen(
            updateWalletInfo()
        )
    }

    private func updateWalletInfo() -> Completable {
        let sessionTokenSingle = authenticationService.getSessionToken()
        let signedRetailToken = walletService.getSignedRetailToken()
        return Single.zip(sessionTokenSingle, signedRetailToken, resultSelector: {
            return ($0, $1)
        }).flatMap { (sessionToken, signedRetailToken) -> Single<NabuUser> in

            // Error checking
            guard signedRetailToken.success else {
                return Single.error(NetworkError.generic(message: "Signed retail token failed."))
            }

            guard let jwtToken = signedRetailToken.token else {
                return Single.error(NetworkError.generic(message: "Signed retail token is nil."))
            }

            // If all passes, send JWT to Nabu
            let headers = [HttpHeaderField.authorization: sessionToken.token]
            let payload = ["jwt": jwtToken]
            return KYCNetworkRequest.request(
                put: .updateWalletInformation,
                parameters: payload,
                headers: headers,
                type: NabuUser.self
            )
        }.do(onSuccess: { user in
            Logger.shared.debug("""
                Successfully updated user: \(user.personalDetails?.identifier ?? "").
                Mobile number: \(user.mobile?.phone ?? "")
            """)
        }).asCompletable()
    }
}

extension Wallet {
    func changeMobileNumber(_ number: String) -> Completable {
        return Completable.create(subscribe: { [unowned self] observer -> Disposable in
            self.changeMobileNumber(number, success: {
                observer(.completed)
            }, error: {
                observer(.error(NetworkError.generic(message: "Failed to change mobile number.")))
            })
            return Disposables.create()
        })
    }

    func verifyMobileNumber(_ code: String) -> Completable {
        return Completable.create(subscribe: { [unowned self] observer -> Disposable in
            self.verifyMobileNumber(code, success: {
                observer(.completed)
            }, error: {
                observer(.error(NetworkError.generic(message: "Failed to change mobile number.")))
            })
            return Disposables.create()
        })
    }
}
