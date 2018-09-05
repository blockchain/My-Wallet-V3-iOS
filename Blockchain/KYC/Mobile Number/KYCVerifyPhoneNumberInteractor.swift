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
    private let authenticationService: KYCAuthenticationService
    private let wallet: Wallet
    private let walletService: WalletService

    init(
        authenticationService: KYCAuthenticationService = KYCAuthenticationService.shared,
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
    ///   - number: the number to verify
    ///   - code: the code sent to the mobile number
    /// - Returns: a Completable which completes if the verification process succeeds
    ///            otherwise, it will emit an error.
    func verify(number: String, code: String) -> Completable {
        do {
            // Sequence of operations when verifying the mobile number:
            // 1. verify phone number on the user's wallet
            // 2. obtain a JWT token from the user's wallet
            // 3. send the JWT token to Nabu
            let phoneNumber = try self.phoneNumberKit.parse(number)
            let formattedPhoneNumber = self.phoneNumberKit.format(phoneNumber, toType: .e164)

            Logger.shared.debug("Verifying number: '\(formattedPhoneNumber)' with code: '\(code)'")

            return wallet.verifyMobileNumber(
                code
            ).andThen(
                updateWalletInfo()
            )
        } catch {
            return Completable.error(error)
        }
    }

    private func updateWalletInfo() -> Completable {
        let sessionTokenSingle = authenticationService.getKycSessionToken()
        let signedRetailToken = walletService.getSignedRetailToken()
        return Single.zip(sessionTokenSingle, signedRetailToken, resultSelector: {
            return ($0, $1)
        }).flatMap { (sessionToken, signedRetailToken) -> Single<KYCUser> in

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
                type: KYCUser.self
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
