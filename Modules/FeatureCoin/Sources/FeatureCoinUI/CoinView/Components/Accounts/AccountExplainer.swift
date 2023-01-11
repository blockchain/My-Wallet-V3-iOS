// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

struct AccountExplainer: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let account: Account.Snapshot
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .trailing) {
            IconButton(icon: Icon.closev2.circle(), action: onClose)
                .frame(width: 24.pt, height: 24.pt)
                .padding(.trailing, 8.pt)
            VStack(alignment: .center, spacing: 20) {
                let explainer = account.accountType.explainer
                account.accountType.icon
                    .color(.semantic.primary)
                    .frame(width: 48.pt, height: 48.pt)
                VStack(spacing: 8) {
                    Text(explainer.title)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(explainer.body)
                        .multilineTextAlignment(.center)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                }
                PrimaryButton(title: explainer.action) {
                    withAnimation(.spring()) {
                        app.post(
                            event: blockchain.ux.asset.account.explainer.accept[].ref(to: context),
                            context: context + [
                                blockchain.ux.asset.account: account
                            ]
                        )
                    }
                }
            }
        }
        .padding([.leading, .trailing], Spacing.padding2)
        .padding(.bottom, 20.pt)
    }
}

extension Account.AccountType {

    struct Explainer {
        let title: String
        let body: String
        let action: String
    }

    var explainer: Explainer {
        switch self {
        case .trading:
            return .trading
        case .interest:
            return .rewards
        case .privateKey:
            return .privateKey
        case .exchange:
            return .exchange
        case .staking:
            return .staking
        case .activeRewards:
            return .active
        }
    }
}

extension Account.AccountType.Explainer {

    private typealias Localization = LocalizationConstants.Coin.Account.Explainer

    static let privateKey = Self(
        title: Localization.privateKey.title,
        body: Localization.privateKey.body,
        action: Localization.privateKey.action
    )

    static let trading = Self(
        title: Localization.trading.title,
        body: Localization.trading.body,
        action: Localization.trading.action
    )

    static let rewards = Self(
        title: Localization.rewards.title,
        body: Localization.rewards.body,
        action: Localization.rewards.action
    )

    static let exchange = Self(
        title: Localization.exchange.title,
        body: Localization.exchange.body,
        action: Localization.exchange.action
    )

    static let staking = Self(
        title: Localization.staking.title,
        body: Localization.staking.body,
        action: Localization.staking.action
    )

    static let active = Self(
        title: Localization.active.title,
        body: Localization.active.body,
        action: Localization.active.action
    )
}

// swiftlint:disable type_name
struct AccountExplainer_PreviewProvider: PreviewProvider {

    static var previews: some View {
        AccountExplainer(account: .preview.privateKey, onClose: {})
        AccountExplainer(account: .preview.trading, onClose: {})
        AccountExplainer(account: .preview.rewards, onClose: {})
    }
}
