//
//  StellarAirdropRegistrationService.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

struct StellarRegisterCampaignResponse: Codable {
    let message: String
}

struct StellarRegisterCampaignPayload: Codable {
    let data: [String: String]
    let newUser: Bool
}

protocol StellarAirdropRegistrationAPI {
    func registerForCampaign(xlmAccount: WalletXlmAccount, nabuUser: NabuUser) -> Single<StellarRegisterCampaignResponse>
}

class StellarAirdropRegistrationService: StellarAirdropRegistrationAPI {

    private let appSettings: BlockchainSettings.App
    private let nabuAuthenticationService: NabuAuthenticationService

    init(
        appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
        nabuAuthenticationService: NabuAuthenticationService = NabuAuthenticationService.shared
    ) {
        self.appSettings = appSettings
        self.nabuAuthenticationService = nabuAuthenticationService
    }

    func registerForCampaign(xlmAccount: WalletXlmAccount, nabuUser: NabuUser) -> Single<StellarRegisterCampaignResponse> {
        return nabuAuthenticationService.getSessionToken()
            .flatMap { [weak self] authToken -> Single<StellarRegisterCampaignResponse> in
                guard let strongSelf = self else {
                    return Single.never()
                }
                return strongSelf.sendNetworkCall(xlmAccount: xlmAccount, nabuUser: nabuUser, authToken: authToken)
            }
    }

    private func sendNetworkCall(
        xlmAccount: WalletXlmAccount,
        nabuUser: NabuUser,
        authToken: NabuSessionTokenResponse
    ) -> Single<StellarRegisterCampaignResponse> {
        guard let base = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Single.never()
        }
        guard let endpoint = URL.endpoint(
            base,
            pathComponents: ["users", "register-campaign"],
            queryParameters: nil
        ) else {
            return Single.never()
        }
        let data = ["x-campaign-address": xlmAccount.publicKey]
        let isNewUser = (nabuUser.status == .none) && !appSettings.isCompletingKyc
        let payload = StellarRegisterCampaignPayload(
            data: data,
            newUser: isNewUser
        )
        guard let postPayload = try? JSONEncoder().encode(payload) else {
            return Single.never()
        }
        return NetworkRequest.PUT(
            url: endpoint,
            body: postPayload,
            token: authToken.token,
            type: StellarRegisterCampaignResponse.self,
            headers: ["X-CAMPAIGN": "sunriver"]
        )
    }
}
