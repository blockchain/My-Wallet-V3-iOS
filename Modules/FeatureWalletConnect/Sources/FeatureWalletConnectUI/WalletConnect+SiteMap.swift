// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Errors
import FeatureWalletConnectDomain
import Foundation
import SwiftUI
import Web3Wallet

public struct WalletConnectSiteMap {
    struct Error: LocalizedError {
        let message: String
        let tag: Tag.Reference
        let context: Tag.Context

        var errorDescription: String? {
            "\(tag.string): \(message)"
        }
    }

    public init() { }

    @MainActor
    @ViewBuilder
    public func view(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        switch ref {
        case blockchain.ux.wallet.connect.pair.request:
            let sessionProposal = try context[blockchain.ux.wallet.connect.pair.request.proposal].decode(WalletConnectProposal.self)
            WalletConnectEventViewV2(state: .request)
                .context(
                    [blockchain.ux.wallet.connect.pair.request.proposal: sessionProposal]
                )
        case blockchain.ux.wallet.connect.pair.settled:
            let sessionProposal = try context[blockchain.ux.wallet.connect.pair.settled.session].decode(WCSessionV2.self)
            WalletConnectEventViewV2(state: .success)
                .context(
                    [blockchain.ux.wallet.connect.pair.settled.session: sessionProposal]
                )
        case blockchain.ux.wallet.connect.failure:
            WalletConnectEventFailureView()
                .context(context)
        case blockchain.ux.wallet.connect.session.details:
            let details = try context[blockchain.ux.wallet.connect.session.details.model].decode(WalletConnectPairings.self)
            DAppDetailsView(details: details)
        case blockchain.ux.wallet.connect.manage.sessions:
            DAppManageView()
        case blockchain.ux.wallet.connect.auth.request:
            let request = try context[blockchain.ux.wallet.connect.auth.request.payload].decode(WalletConnectAuthRequest.self)
            WalletConnectAuthView(request: request)
                .context(
                    [blockchain.coin.core.account.id: request.accountInfo.identifier]
                )
        default:
            throw Error(message: "No view", tag: ref, context: context)
        }
    }
}
