// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureReferralDomain
import Foundation
import SwiftUI

public final class ReferralAppObserver: Client.Observer {

    unowned let app: AppProtocol
    let referralService: ReferralServiceAPI

    public init(
        app: AppProtocol,
        referralService: ReferralServiceAPI
    ) {
        self.app = app
        self.referralService = referralService
    }

    var observers: [BlockchainEventSubscription] {
        [
            fetchReferral,
            walletCreated
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var walletCreated = app.on(blockchain.user.wallet.created) { [unowned self] _ in
        guard try await app.get(blockchain.app.configuration.referral.is.enabled) else { return }
        try await referralService.createReferral(
            with: app.get(blockchain.user.creation.referral.code)
        )
        .await()
    }

    lazy var fetchReferral = app.on(
        blockchain.session.event.did.sign.in,
        blockchain.ux.kyc.event.did.finish,
        blockchain.ux.home.event.did.pull.to.refresh
    ) { [unowned self] _ in
        do {
            guard try await app.get(blockchain.app.configuration.referral.is.enabled) else { return }
            let campaign = try await referralService.fetchReferralCampaign().await()
            app.post(value: campaign, of: blockchain.user.referral.campaign)
        } catch {
            app.state.clear(blockchain.user.referral.campaign)
        }
    }
}
