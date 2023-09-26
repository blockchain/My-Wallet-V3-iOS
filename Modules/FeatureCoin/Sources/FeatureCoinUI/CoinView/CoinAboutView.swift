// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI

struct CoinAboutView: View {

    private typealias L10n = LocalizationConstants.Coin

    @BlockchainApp var app
    private let value: AboutAssetInformation?
    private let currency: CryptoCurrency
    private let isExpanded: Bool
    private let toggleIsExpaded: () -> Void

    init(
        currency: CryptoCurrency,
        value: AboutAssetInformation?,
        isExpanded: Bool,
        toggleIsExpaded: @escaping () -> Void
    ) {
        self.currency = currency
        self.value = value
        self.isExpanded = isExpanded
        self.toggleIsExpaded = toggleIsExpaded
    }

    @ViewBuilder
    var body: some View {
        if let value, value.isEmpty.isNo {
            VStack(alignment: .leading, spacing: 0) {
                title
                VStack(alignment: .leading, spacing: Spacing.padding3) {
                    let items = detailsItems(value)
                    if items.isNotEmpty {
                        details(items)
                    }
                    if let description = value.description, description.isNotEmpty {
                        about(description)
                    }
                    if value.website.isNotNil || value.whitepaper.isNotNil {
                        buttons(value)
                    }
                }
                .padding(.horizontal, Spacing.padding2)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var title: some View {
        HStack(spacing: 0) {
            Text(L10n.Label.Title.aboutCrypto.interpolating(currency.name))
                .typography(.body2)
                .foregroundColor(.semantic.body)
            Spacer()
        }
        .padding(.vertical, Spacing.padding1)
        .padding(.horizontal, Spacing.padding2)
    }

    @ViewBuilder
    private func details(_ items: [DetailRow]) -> some View {
        let last = items.last
        VStack(spacing: 0) {
            ForEach(items, id: \.title) { item in
                detailRow(
                    title: item.title,
                    value: item.value,
                    copyableValue: item.copyableValue
                )
                if item != last {
                    PrimaryDivider()
                }
            }
        }
        .cornerRadius(16)
    }

    private func detailsItems(_ value: AboutAssetInformation) -> [DetailRow] {
        guard app.currentMode == .pkw else {
            return []
        }
        var items: [DetailRow] = []
        if let network = value.network {
            items.append(.init(
                title: L10n.About.network,
                value: network,
                copyableValue: nil
            ))
        }
        if let contractAddress = value.contractAddress {
            items.append(.init(
                title: L10n.About.contract,
                value: contractAddress.obfuscate(keeping: 4),
                copyableValue: contractAddress
            ))
        }
        if let marketCap = value.marketCap {
            items.append(.init(
                title: L10n.About.marketCap,
                value: marketCap.toDisplayString(includeSymbol: true, format: .forceShortened),
                copyableValue: nil
            ))
        }
        return items
    }

    struct DetailRow: Equatable {
        let title: String
        let value: String
        let copyableValue: String?
    }

    @ViewBuilder
    private func detailRow(
        title: String,
        value: String,
        copyableValue: String?
    ) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
            if let copyableValue {
                Icon.copy
                    .with(length: 12.pt)
                    .color(.semantic.muted)
                    .padding(Spacing.textSpacing)
                    .onTapGesture { $app.post(event: blockchain.ux.asset.bio.copy.contract) }
                    .batch {
                        set(blockchain.ux.asset.bio.copy.contract.then.copy, to: copyableValue)
                    }
            }
            Spacer()
            Text(value)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
    }

    @ViewBuilder
    private func about(_ value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.padding2) {
            Text(rich: value)
                .lineLimit(isExpanded ? nil : 6)
                .typography(.paragraph1)
                .foregroundColor(.semantic.title)
            if isExpanded.isNo {
                SmallMinimalButton(
                    title: L10n.Button.Title.readMore,
                    action: {
                        withAnimation { toggleIsExpaded() }
                    }
                )
            }
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
        .cornerRadius(16)
    }

    @ViewBuilder
    private func buttons(_ value: AboutAssetInformation) -> some View {
        HStack {
            websiteButton(value)
            whitepaperButton(value)
            Spacer()
        }
    }

    @ViewBuilder
    private func websiteButton(_ value: AboutAssetInformation) -> some View {
        if let url = value.website {
            SmallMinimalButton(
                title: L10n.Link.Title.visitWebsite,
                leadingView: { Icon.globe.frame(width: 16.pt) },
                action: { $app.post(event: blockchain.ux.asset.bio.visit.website) }
            )
            .batch {
                set(blockchain.ux.asset.bio.visit.website.then.enter.into, to: blockchain.ux.web[url])
            }
        }
    }

    @ViewBuilder
    private func whitepaperButton(_ value: AboutAssetInformation) -> some View {
        if let url = value.whitepaper {
            SmallMinimalButton(
                title: L10n.Link.Title.visitWhitepaper,
                leadingView: {
                    Icon.link
                        .color(.semantic.light)
                        .circle(backgroundColor: .semantic.primary)
                        .frame(width: 16.pt)
                },
                action: { $app.post(event: blockchain.ux.asset.bio.visit.whitepaper) }
            )
            .batch {
                set(blockchain.ux.asset.bio.visit.whitepaper.then.enter.into, to: blockchain.ux.web[url])
            }
        }
    }
}

struct CoinAboutView_PreviewProvider: PreviewProvider {

    static var previews: some View {
        make(value: infoMinimal, title: "Minimal")
        make(value: infoFull, title: "ERC20")
    }

    private static func make(
        value: AboutAssetInformation?,
        title: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                Divider()
                CoinAboutView(
                    currency: .bitcoin,
                    value: value,
                    isExpanded: false,
                    toggleIsExpaded: {}
                )
                .app(App.preview)
                Divider()
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .previewDisplayName(title)
    }

    static var infoMinimal: AboutAssetInformation {
        AboutAssetInformation(
            description: AssetInformation.preview.description,
            whitepaper: AssetInformation.preview.whitepaper,
            website: AssetInformation.preview.website,
            network: nil,
            marketCap: nil,
            contractAddress: nil
        )
    }

    static var infoFull: AboutAssetInformation {
        AboutAssetInformation(
            description: AssetInformation.preview.description,
            whitepaper: AssetInformation.preview.whitepaper,
            website: AssetInformation.preview.website,
            network: "Ethereum",
            marketCap: FiatValue.create(major: Double(1000000), currency: .USD),
            contractAddress: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
        )
    }
}
