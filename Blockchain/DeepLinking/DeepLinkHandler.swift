//
//  DeepLinkHandler.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Firebase
import PlatformKit

class DeepLinkHandler {

    private let appSettings: BlockchainSettings.App

    init(appSettings: BlockchainSettings.App = BlockchainSettings.App.shared) {
        self.appSettings = appSettings
    }

    func handle(deepLink: URL) {
        Logger.shared.debug("Attempting to handle deep link \(deepLink.absoluteString)")
        guard let route = DeepLinkRoute.route(from: deepLink),
            let payload = DeepLinkPayload.create(from: deepLink) else {
            return
        }

        switch route {
        case .xlmAirdop:
            handleXlmAirdrop(payload.params)
        case .kyc,
             .kycVerifyEmail:
            handleKyc()
        case .kycDocumentResubmission:
            handleKycDocumentResubmission(payload.params)
        }
    }

    private func handleXlmAirdrop(_ params: [String: String]) {
        appSettings.didTapOnAirdropDeepLink = true
        appSettings.didAttemptToRouteForAirdrop = false
        Analytics.setUserProperty(AnalyticsService.Campaigns.sunriver.rawValue, forName: "campaign")
    }

    private func handleKycDocumentResubmission(_ params: [String: String]) {
        appSettings.didTapOnDocumentResubmissionDeepLink = true
        appSettings.documentResubmissionLinkReason = params["resubmission_reason"]
    }

    private func handleKyc() {
        appSettings.didTapOnKycDeepLink = true
    }
}
