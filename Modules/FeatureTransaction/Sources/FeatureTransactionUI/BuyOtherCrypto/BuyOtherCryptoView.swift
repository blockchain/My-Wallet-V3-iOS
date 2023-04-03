// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import BlockchainUI
import DIKit
import Foundation
import Localization
import MoneyDomainKit
import SwiftUI

public struct BuyOtherCryptoView: View {
    typealias Localization = LocalizationConstants.Transaction.Buy.Completion.BuyOtherCrypto
    @BlockchainApp var app
    @Environment(\.context) var context
    @State private var mostPopular: [CurrencyType] = [.crypto(.bitcoin), .crypto(.ethereum)]
    @State private var pairs: [CurrencyPair] = []
    @State private var buyTransferTargetCurrency: String?

    var popular: [CurrencyPair] {
        pairs.sorted(
            like: mostPopular,
            using: \.base,
            equals: \.self
        )
        .prefix(mostPopular.count)
        .filter { $0.base.code != buyTransferTargetCurrency }
        .array
    }

    public init () {}

    public var body: some View {
        ZStack {
            Color
                .WalletSemantic
                .light
                .ignoresSafeArea()
            contentView
        }
        .bindings(managing: print) {
            subscribe($buyTransferTargetCurrency, to: blockchain.ux.buy.last.bought.asset)
            subscribe($mostPopular, to: blockchain.app.configuration.buy.most.popular.assets)
            subscribe($pairs.animation(.easeOut), to: blockchain.api.nabu.gateway.simple.buy.pairs.ids)
        }
    }

    func print(update: BindingsUpdate) {
        Swift.print(buyTransferTargetCurrency)
        Swift.print("🔥", update)
    }

    var contentView: some View {
        VStack(spacing: 8) {
            labelsView
            mostPopularView
            Spacer()
            ctaButtonsView
        }
        .padding(Spacing.padding2)
    }

    var labelsView: some View {
        VStack(spacing: 8) {
            Text(Localization.title)
                .typography(.title3)
                .foregroundColor(.WalletSemantic.title)
                .multilineTextAlignment(.center)
            Text(Localization.subtitle)
                .typography(.body1)
                .foregroundColor(.WalletSemantic.body)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.padding2)
    }

    var ctaButtonsView: some View {
        VStack(spacing: 8) {
            PrimaryWhiteButton(title: Localization.maybeLaterCta, action: {
                $app.post(event: blockchain.ux.buy.another.asset.maybe.later.paragraph.row.tap)
                app.state.set(blockchain.ux.buy.another.asset.maybe.later.timestamp, to: Date())
            })
        }
        .batch {
            set(blockchain.ux.buy.another.asset.maybe.later.paragraph.row.tap.then.close, to: true)
        }
    }

    var mostPopularView: some View {
        DividedVStack {
            ForEach(popular, id: \.self) { pair in
                BuyEntryRow(id: blockchain.ux.buy.another.asset.select.target.most.popular, pair: pair)
                    .context([blockchain.ux.buy.another.asset.select.target.most.popular.section.list.item.id: pair.base.code])
            }
        }
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
    }

    private var loadingRow: some View {
        SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
    }

    private var loadingDivider: some View {
        Divider().foregroundColor(.WalletSemantic.light)
    }
}

@MainActor
struct BuyEntryRow: View {
    @BlockchainApp var app

    let id: L & I_blockchain_ui_type_task
    let pair: CurrencyPair

    @State private var price: MoneyValue?
    @State private var delta: Decimal?
    @State var fastRisingMinDelta: Double?

    var body: some View {
        if #available(iOS 16.0, *) {
            content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
        } else {
            content
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncMedia(
                        url: pair.base.cryptoCurrency?.logoURL
                    )
                    .frame(width: 24.pt, height: 24.pt)
                }
                Spacer()
                    .frame(width: 16)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pair.base.cryptoCurrency?.name ?? "")
                            .typography(.paragraph2)
                            .foregroundColor(.WalletSemantic.title)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        Text(pair.base.cryptoCurrency?.code ?? "")
                            .typography(.caption1)
                            .foregroundColor(.WalletSemantic.body)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }

                    if Decimal((fastRisingMinDelta ?? 100) / 100).isLessThanOrEqualTo(delta ?? 0) {
                        Icon
                            .fireFilled
                            .micro()
                            .color(.semantic.warningMuted)
                    }

                    Spacer()

                    if let price, price.isPositive {
                        VStack(alignment: .trailing, spacing: 4.pt) {
                            Text(price.toDisplayString(includeSymbol: true))
                                .typography(.paragraph1)
                                .foregroundColor(.WalletSemantic.title)
                                .scaledToFill()
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            if let delta {
                                delta.view
                                    .typography(.caption1)
                                    .foregroundColor(delta.color)
                                    .scaledToFill()
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }
                        }
                    } else {
                        VStack(alignment: .trailing) {
                            Text("....................")
                            Text(".....")
                        }
                        .redacted(reason: .placeholder)
                    }
                }
            }
        }
        .padding(Spacing.padding2)
        .onTapGesture {
            $app.post(
                event: id.paragraph.row.tap,
                context: [blockchain.ux.asset.id: pair.base.code]
            )
        }
        .bindings {
            subscribe($fastRisingMinDelta, to: blockchain.app.configuration.prices.rising.fast.percent)
            subscribe($price, to: blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].quote.value)
            subscribe($delta, to: blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].delta.since.yesterday)
        }
        .batch {
            set(id.paragraph.row.tap.then.close, to: true)
            set(id.paragraph.row.tap.then.emit, to: blockchain.ux.asset.buy)
        }
    }
}

extension Decimal {
    var color: Color {
        if isSignMinus {
            return Color.WalletSemantic.pink
        } else if isZero {
            return Color.WalletSemantic.body
        } else {
            return Color.WalletSemantic.success
        }
    }

    @ViewBuilder fileprivate var view: some View {
        Group {
            if #available(iOS 15.0, *) {
                Text(isZero ? "" : (isSignMinus ? "↓" : "↑")) + Text(formatted(.percent.precision(.fractionLength(2))))
            } else {
                Text(isZero ? "" : (isSignMinus ? "↓" : "↑"))
            }
        }
        .foregroundColor(isZero ? .semantic.primary : (isSignMinus ? .semantic.pink : .semantic.success))
    }
}

struct BuyOtherView_Preview: PreviewProvider {
    static var previews: some View {
        BuyOtherCryptoView()
            .app(App.preview)
    }
}
