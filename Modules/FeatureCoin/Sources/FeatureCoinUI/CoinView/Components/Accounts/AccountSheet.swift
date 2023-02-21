// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import FeatureCoinDomain
import MoneyKit
import SwiftUI
import ToolKit

struct AccountSheet: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let account: Account.Snapshot
    var isVerified: Bool
    let onClose: () -> Void

    private var isNotVerified: Bool { !isVerified }

    var actions: [Account.Action] {
        account.actions
            .union(account.importantActions)
            .intersection(account.allowedActions)
            .sorted(like: account.allowedActions)
    }

    var maxHeight: Length {
        (85 / actions.count).clamped(to: 8..<11).vh
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                AsyncMedia(url: account.cryptoCurrency.logoURL)
                    .frame(width: 24, height: 24)
                Text(account.assetName)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                Spacer()
                IconButton(icon: Icon.closev2.circle(), action: onClose)
                    .frame(width: 24.pt, height: 24.pt)
            }
            .padding(.horizontal, Spacing.padding2)
            .padding(.bottom, Spacing.padding3)
            Group {
                if let fiat = account.fiat, let crypto = account.crypto {
                    BalanceSectionHeader(
                        title: fiat.displayString,
                        subtitle: crypto.displayString
                    )
                } else {
                    BalanceSectionHeader(
                        title: "......",
                        subtitle: "............"
                    )
                    .redacted(reason: .placeholder)
                }
            }
            .padding([.top, .bottom], 8.pt)
            let resolved = isNotVerified && account.isPrivateKey
                ? [.send, .receive, .swap, .sell, .activity]
                : actions
            ForEach(resolved) { action in
                PrimaryDivider()
                if actions.contains(action) {
                    PrimaryRow(
                        title: action.title,
                        subtitle: action.description.interpolating(account.cryptoCurrency.displayCode),
                        leading: {
                            action.icon.circle()
                                .accentColor(.semantic.title)
                                .frame(maxHeight: 24.pt)
                        },
                        action: {
                            onClose()
                            app.post(event: action.id[].ref(to: context), context: context)
                        }
                    )
                    .accessibility(identifier: action.id(\.id))
                    .frame(maxHeight: maxHeight)
                } else {
                    LockedAccountRow(
                        title: action.title,
                        subtitle: action.description.interpolating(account.cryptoCurrency.displayCode),
                        icon: action.icon.circle()
                    )
                    .accessibility(identifier: action.id(\.id))
                    .frame(maxHeight: maxHeight)
                }
            }
        }
        .batch(
            .set(
                blockchain.ux.asset.account.rewards.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["savings"].asset[account.cryptoCurrency.code].summary
            ),
            .set(
                blockchain.ux.asset.account.staking.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["staking"].asset[account.cryptoCurrency.code].summary
            ),
            .set(
                blockchain.ux.asset.account.active.rewards.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["earn_cc1w"].asset[account.cryptoCurrency.code].summary
            )
        )
    }
}

extension Account.Snapshot {

    var color: Color {
        cryptoCurrency.color
    }

    var allowedActions: [Account.Action] {
        switch accountType {
        case .interest:
            return [.rewards.withdraw, .rewards.deposit, .rewards.summary, .activity]
        case .privateKey:
            return [.send, .receive, .swap, .sell, .activity]
        case .trading:
            return [.buy, .sell, .swap, .send, .receive, .activity]
        case .exchange:
            return [.exchange.withdraw, .exchange.deposit]
        case .staking:
            return [.staking.deposit, .staking.summary, .activity]
        case .activeRewards:
            return [.active.withdraw, .active.deposit, .active.summary, .activity]
        }
    }

    var importantActions: [Account.Action] {
        switch accountType {
        case .interest:
            return [.rewards.withdraw, .rewards.deposit, .rewards.summary]
        case .staking:
            return [.staking.deposit, .staking.summary]
        case .activeRewards:
            return [.active.deposit, .active.summary]
        default:
            return []
        }
    }
}

extension CryptoCurrency {

    public var color: Color {
        assetModel.spotColor.map(Color.init(hex:))
            ?? (CustodialCoinCode(rawValue: code)?.spotColor).map(Color.init(hex:))
            ?? Color(hex: ERC20Code.spotColor(code: code))
    }
}

struct AccountSheetPreviewProvider: PreviewProvider {
    static var previews: some View {
        AccountSheet(
            account: .preview.trading,
            isVerified: true,
            onClose: {}
        )
    }
}
