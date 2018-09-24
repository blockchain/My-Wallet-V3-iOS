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
        let sessionTokenSingle = authenticationService.getSessionToken()
        let signedRetailToken = walletService.getSignedRetailToken()
        return Single.zip(sessionTokenSingle, signedRetailToken, resultSelector: {
            return ($0, $1)
        }).flatMapCompletable { (sessionToken, signedRetailToken) -> Completable in
            var payload = [
                "jwt": signedRetailToken.token ?? "",
                "countryCode": country.code
            ]
            if let notify = shouldBeNotifiedWhenAvailable {
                payload["notifyWhenAvailable"] = notify.description
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
