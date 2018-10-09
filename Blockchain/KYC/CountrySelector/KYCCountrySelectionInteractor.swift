//
//  KYCCountrySelectionInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class KYCCountrySelectionInteractor {

    private let authenticationService: NabuAuthenticationService
    private let walletService: WalletService

    init(
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        walletService: WalletService = WalletService.shared
    ) {
        self.authenticationService = authenticationService
        self.walletService = walletService
    }

    func selected(country: KYCCountry, shouldBeNotifiedWhenAvailable: Bool? = nil) -> Disposable {
        return sendSelection(countryCode: country.code, shouldBeNotifiedWhenAvailable: shouldBeNotifiedWhenAvailable)
    }

    func selected(state: KYCState, shouldBeNotifiedWhenAvailable: Bool? = nil) -> Disposable {
        return sendSelection(
            countryCode: state.countryCode,
            state: state.countryCode,
            shouldBeNotifiedWhenAvailable: shouldBeNotifiedWhenAvailable
        )
    }

    private func sendSelection(
        countryCode: String,
        state: String? = nil,
        shouldBeNotifiedWhenAvailable: Bool? = nil
    ) -> Disposable {
        let sessionTokenSingle = authenticationService.getSessionToken()
        let signedRetailToken = walletService.getSignedRetailToken()
        return Single.zip(sessionTokenSingle, signedRetailToken, resultSelector: {
            return ($0, $1)
        }).flatMapCompletable { (sessionToken, signedRetailToken) -> Completable in
            var payload = [
                "jwt": signedRetailToken.token ?? "",
                "countryCode": countryCode
            ]
            if let notify = shouldBeNotifiedWhenAvailable {
                payload["notifyWhenAvailable"] = notify.description
            }
            if let state = state {
                payload["state"] = state
            }
            let headers = [HttpHeaderField.authorization: sessionToken.token]
            return KYCNetworkRequest.request(post: .country, parameters: payload, headers: headers)
        }.subscribe(onCompleted: {
            Logger.shared.debug("Successfully notified the server of the selected country.")
        }, onError: { error in
            Logger.shared.error("Failed to notify the server of the selected country: \(error)")
        })
    }
}
