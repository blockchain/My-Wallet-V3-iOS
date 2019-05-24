//
//  KYCCoinifyAuthenticator.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformKit

class KYCCoinifyAuthenticator {
    
    // MARK: Coinify Errors
    
    enum KYCCoinifyError: Error {
        case noCountryProvided
        case noPartnerID
        case `default`
    }
    
    // MARK: Public Typealias
    
    typealias Token = String
    
    // MARK: Private Static Properties
    
    private static let fieldParameter: String = "email%7Cwallet_age"
    private static let partnerParameter: String = "coinify"
    private static let apiCode: String = "35e77459-723f-48b0-8c9e-6e9e8f54fbd3"
    
    // MARK: Private Model
    
    struct CoinifyTraderPayload: Encodable {
        let coinifyTraderId: Int
    }
    
    // MARK: Private Properties
    
    private let wallet: Wallet
    private let authenticationService: NabuAuthenticationService
    
    // MARK: - Initialization
    
    init(wallet: Wallet = WalletManager.shared.wallet,
         authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared
        ) {
        self.authenticationService = authenticationService
        self.wallet = wallet
    }
    
    func createCoinifyTrader() -> Single<CoinifyMetadata> {
        let user = BlockchainDataRepository.shared.nabuUser
            .take(1)
            .asSingle()
        return Single.zip(user, partnerToken(), WalletService.shared.walletOptions).flatMap {
            let nabuUser = $0.0
            let token = $0.1.token
            let walletOptions = $0.2
            
            guard let countryCode = nabuUser.address?.countryCode else {
                return Single.error(KYCCoinifyError.noCountryProvided)
            }
            
            guard let partnerID = walletOptions.coinifyMetadata?.partnerId else {
                return Single.error(KYCCoinifyError.noPartnerID)
            }
            
            return self.signUp(
                partnerToken: token,
                countryCode: countryCode,
                partnerID: partnerID
                ).map {
                    return CoinifyMetadata(
                        identifier: $0.traderIdentifier,
                        token: $0.offlineToken
                    )
            }
        }
    }
    
    func updateCoinifyIdentifer(_ coinifyID: Int) -> Completable {
        guard let baseURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Completable.error(KYCCoinifyError.default)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["kyc", "update-coinify-id"],
            queryParameters: nil
            ) else {
                return Completable.error(KYCCoinifyError.default)
        }
        
        let payload = CoinifyTraderPayload(coinifyTraderId: coinifyID)
        
        return authenticationService.getSessionToken().flatMapCompletable {
            return NetworkRequest.PUT(
                url: endpoint,
                body: try? JSONEncoder().encode(payload),
                headers: [HttpHeaderField.authorization: $0.token]
            )
        }
    }
    
    func partnerToken() -> Single<KYCCoinifySignedToken> {
        guard wallet.isInitialized() else {
            return Single.error(WalletError.notInitialized)
        }
        
        guard let guid = self.wallet.guid else {
            Logger.shared.warning("Cannot get Nabu authentication token, guid is nil.")
            return Single.error(WalletError.notInitialized)
        }
        
        guard let sharedKey = BlockchainSettings.App.shared.sharedKey else {
            AlertViewPresenter.shared.showKeychainReadError()
            return Single.error(WalletError.notInitialized)
        }
        
        let headers = [
            HttpHeaderField.appVersion: Bundle.applicationVersion ?? "",
            HttpHeaderField.clientType: HttpHeaderValue.clientTypeApp]
        
        guard let baseURL = URL(string: BlockchainAPI.shared.walletUrl) else {
            return Single.error(NetworkError.generic(message: nil))
        }
        
        guard let url = URL.endpoint(
            baseURL,
            pathComponents: ["wallet", "signed-token"],
            queryParameters: ["guid": guid,
                              "sharedKey": sharedKey,
                              "fields": KYCCoinifyAuthenticator.fieldParameter,
                              "partner": KYCCoinifyAuthenticator.partnerParameter,
                              "api_code": KYCCoinifyAuthenticator.apiCode
            ]) else { return Single.error(NetworkError.generic(message: nil)) }
        
        return NetworkRequest.GET(url: url, headers: headers, type: KYCCoinifySignedToken.self)
    }
    
    func signUp(partnerToken: String, countryCode: String, partnerID: Int) -> Single<KYCCoinifyTraderResponse> {
        guard self.wallet.isInitialized() else { return Single.error(WalletError.notInitialized) }
        
        guard let email = self.wallet.getEmail() else {
            Logger.shared.warning("Cannot get Nabu authentication token, email is nil.")
            return Single.error(WalletError.notInitialized)
        }
        
        let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        
        guard let baseURL = URL(string: BlockchainAPI.shared.coinifyEndpoint) else {
            return Single.error(NetworkError.generic(message: nil))
        }
        
        guard let url = URL.endpoint(
            baseURL,
            pathComponents: ["signup", "trader"],
            queryParameters: nil) else {
                return Single.error(NetworkError.generic(message: nil))
        }
        
        let payload = KYCCoinifySignupPayload(
            trustedEmailValidationToken: partnerToken,
            email: email,
            defaultCurrency: currencyCode,
            partnerId: partnerID,
            generateOfflineToken: true,
            profile: .init(countryCode: countryCode)
        )
        
        let data = try? JSONEncoder().encode(payload)
        
        return NetworkRequest.POST(
            url: url,
            body: data,
            type: KYCCoinifyTraderResponse.self
        )
    }
    
}
