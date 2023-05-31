// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureWalletConnectDomain
import SwiftUI
import Web3Wallet

struct WalletConnectAuthView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @State private var balance: MoneyValue?
    @State private var exchangeRate: MoneyValue?

    var currency: CryptoCurrency? {
        balance?.currency.cryptoCurrency
    }

    var price: MoneyValue? {
        guard let balance, let exchangeRate else { return nil }
        return balance.convert(using: exchangeRate)
    }

    private let request: WalletConnectAuthRequest

    init(request: WalletConnectAuthRequest) {
        self.request = request
    }

    var body: some View {
        VStack(spacing: Spacing.padding3) {
            HStack(alignment: .top) {
                Spacer()
                IconButton(icon: .closeCirclev3.small()) {
                    $app.post(event: blockchain.ux.wallet.connect.auth.request.entry.paragraph.button.icon.tap)
                }
                .batch {
                    set(blockchain.ux.wallet.connect.auth.request.entry.paragraph.button.icon.tap.then.close, to: true)
                }
            }
            VStack(spacing: Spacing.padding1) {
                Icon.walletConnect
                    .with(length: 88.pt)
                Text(L10n.AuthRequest.title)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(request.domain)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
            }
            .padding(.top, Spacing.padding2)
            VStack(spacing: Spacing.padding3) {
                VStack(alignment: .leading, spacing: Spacing.padding1) {
                    Text(L10n.AuthRequest.messageTitle)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(request.formattedMessage)
                            .typography(.body1)
                            .foregroundColor(.semantic.body)
                            .lineLimit(nil)
                            .padding(Spacing.padding2)
                    }
                    .frame(maxWidth: .infinity, minHeight: 144.0, maxHeight: 160.0)
                    .background(
                        RoundedRectangle(cornerRadius: Spacing.padding1)
                            .fill(Color.semantic.background)
                    )
                }
                HStack(spacing: Spacing.padding2) {
                    request.accountInfo
                        .network
                        .nativeAsset
                        .logo()
                    VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                        Text(request.accountInfo.label)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.title)
                        Text(request.accountInfo.address)
                            .typography(.caption1)
                            .foregroundColor(.semantic.text)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(width: 90.pt)
                    }
                    Spacer()
                    Group {
                        if let price, price.isPositive {
                            Text(price.toDisplayString(includeSymbol: true))
                        } else {
                            Text("..........").redacted(reason: .placeholder)
                        }
                    }
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
                }
                .padding(Spacing.padding2)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.padding1)
                        .fill(Color.semantic.background)
                )
                HStack(spacing: Spacing.padding1) {
                    MinimalButton(title: L10n.AuthRequest.cancel) {
                        app.post(
                            event: blockchain.ux.wallet.connect.auth.reject,
                            context: [blockchain.ux.wallet.connect.auth.request.payload: request.request]
                        )
                        app.post(event: blockchain.ui.type.action.then.close)
                    }
                    PrimaryButton(title: L10n.AuthRequest.confirm) {
                        app.post(
                            event: blockchain.ux.wallet.connect.auth.approve,
                            context: [blockchain.ux.wallet.connect.auth.request.payload: request.request]
                        )
                    }
                }
            }
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.light.ignoresSafeArea())
        .bindings {
            subscribe($balance, to: blockchain.coin.core.account.balance.available)
            if let currency {
                subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
            }
        }
    }
}
