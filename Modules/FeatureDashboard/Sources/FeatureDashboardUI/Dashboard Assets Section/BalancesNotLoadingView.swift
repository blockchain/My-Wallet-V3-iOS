import BlockchainUI
import SwiftUI

public struct BalancesNotLoadingSheet: View {

    @BlockchainApp var app

    private let networksFailing: String

    public init(networksFailing: String) {
        self.networksFailing = networksFailing
    }

    public var body: some View {
        VStack(spacing: 16.pt) {
            VStack(spacing: 24.pt) {
                ZStack(alignment: .bottomTrailing) {
                    Icon.coins
                        .with(length: 88.pt)
                        .circle(backgroundColor: .semantic.light)
                        .iconColor(.semantic.title)
                    Icon.alert
                        .with(length: 44.pt)
                        .iconColor(.semantic.warningMuted)
                        .background(
                            Circle().fill(Color.semantic.background)
                                .frame(width: 59.pt, height: 59.pt)
                        )
                }
                .frame(width: 88.pt, height: 88.pt)
                .padding(.top, Spacing.padding2)
                .padding(.bottom, Spacing.padding1)
                VStack(spacing: 8.pt) {
                    Text(LocalizationConstants.SuperApp.Dashboard.BalancesFailing.alertCardTitle)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(
                        String(
                            format: LocalizationConstants.SuperApp.Dashboard.BalancesFailing.alertCardMessage,
                            networksFailing
                        )
                    )
                    .typography(.body1)
                    .foregroundColor(.semantic.text)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.bottom, Spacing.padding2)
            PrimaryButton(
                title: LocalizationConstants.okString,
                action: {
                    $app.post(event: blockchain.ux.dashboard.defi.balances.failure.sheet.entry.paragraph.button.primary.tap)
                }
            )
        }
        .padding(.top, 40.pt)
        .overlay(
            IconButton(
                icon: .closev2.small().color(.semantic.muted).circle(backgroundColor: .semantic.light),
                action: { $app.post(event: blockchain.ux.dashboard.defi.balances.failure.sheet.article.plain.navigation.bar.button.close.tap) }
            ),
            alignment: .topTrailing
        )
        .padding(.top)
        .padding(.horizontal)
        .background(Color.semantic.background)
        .batch {
            set(blockchain.ux.dashboard.defi.balances.failure.sheet.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            set(blockchain.ux.dashboard.defi.balances.failure.sheet.entry.paragraph.button.primary.tap.then.close, to: true)
        }
    }
}
