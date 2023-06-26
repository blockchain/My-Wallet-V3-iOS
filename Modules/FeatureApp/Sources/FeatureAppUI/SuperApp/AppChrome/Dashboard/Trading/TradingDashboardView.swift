// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import ComposableArchitecture
import DIKit
import FeatureAnnouncementsDomain
import FeatureAnnouncementsUI
import FeatureAppDomain
import FeatureCoinUI
import FeatureCustodialOnboarding
import FeatureDashboardUI
import FeatureTopMoversCryptoUI
import FeatureTransactionUI
import Localization
import MoneyKit
import SwiftUI

struct TradingDashboardView: View {
    @BlockchainApp var app

    let store: StoreOf<TradingDashboard>
    @ObservedObject var viewStore: ViewStore<TradingDashboardView.ViewState, TradingDashboard.Action>

    @State private var scrollOffset: CGPoint = .zero
    @State private var isBlocked = false
    @State private var kycState: Tag = blockchain.user.account.kyc.state.none[]

    var isRejected: Bool { kycState == blockchain.user.account.kyc.state.rejected[] }

    @StateObject private var onboarding = CustodialOnboardingService()

    struct ViewState: Equatable {
        let actions: FrequentActions
        let balance: BalanceInfo?
        let getStartedBuyCryptoAmmounts: [TradingGetStartedAmmountValue]
        var isZeroBalance: Bool { balance?.balance.isZero ?? false }
        var isBalanceLoaded: Bool { balance != nil }
        init(state: TradingDashboard.State) {
            self.actions = state.frequentActions
            self.balance = state.tradingBalance
            self.getStartedBuyCryptoAmmounts = state.getStartedBuyCryptoAmmounts
        }
    }

    init(store: StoreOf<TradingDashboard>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            if onboarding.isSynchronized {
                if onboarding.isFinished {
                    dashboardView
                } else {
                    onboardingView
                }
            } else {
                loadingView
            }
        }
        .superAppNavigationBar(
            leading: { [app] in dashboardLeadingItem(app: app) },
            title: {
                if let balance = viewStore.balance?.balance {
                    balance.typography(.body2)
                        .foregroundColor(.semantic.title)
                }
            },
            trailing: { [app] in dashboardTrailingItem(app: app) },
            titleShouldFollowScroll: true,
            titleExtraOffset: Spacing.padding3,
            scrollOffset: $scrollOffset.y
        )
        .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
        .bindings {
            subscribe($isBlocked, to: blockchain.user.is.blocked)
            subscribe($kycState, to: blockchain.user.account.kyc.state)
        }
        .onAppear {
            onboarding.request()
        }
    }

    var loadingView: some View {
        ZStack {
            BlockchainProgressView()
        }
    }

    var onboardingView: some View {
        VStack {
            if isBlocked {
                blockedView
            } 
            CustodialOnboardingDashboardView(service: onboarding)
        }
    }

    var dashboardView: some View {
        VStack(spacing: Spacing.padding3) {

            Group {
                DashboardMainBalanceView(
                    info: .constant(viewStore.balance),
                    isPercentageHidden: viewStore.isZeroBalance
                )
                .padding([.top], Spacing.padding3)

                if !isRejected {
                    if viewStore.isZeroBalance {
                        FrequentActionsView(actions: viewStore.actions.zeroBalance)
                    } else {
                        FrequentActionsView(actions: viewStore.actions.withBalance)
                    }
                }
            }

            FeatureAnnouncementsView(
                store: store.scope(
                    state: \.announcementsState,
                    action: TradingDashboard.Action.announcementsAction
                )
            )

            if isBlocked {
                blockedView
            }

            if !viewStore.isZeroBalance {
                if isRejected {
                    rejectedView
                } else {
                    DashboardAssetSectionView(
                        store: store.scope(
                            state: \.assetsState,
                            action: TradingDashboard.Action.assetsAction
                        )
                    )
                }
            }

            if !isRejected {
                RecurringBuySection()
                TopMoversSectionView(
                    store: store.scope(state: \.topMoversState, action: TradingDashboard.Action.topMoversAction)
                )
                .padding(.horizontal, Spacing.padding2)
            }

            DashboardActivitySectionView(
                store: store.scope(state: \.activityState, action: TradingDashboard.Action.activityAction)
            )

            Group {
                if !isRejected {
                    DashboardReferralView()
                }
                NewsSectionView(api: blockchain.api.news.all)
                DashboardHelpSectionView()
            }
        }
        .scrollOffset($scrollOffset)
        .task {
            await viewStore.send(.prepare).finish()
        }
        .padding(.bottom, 72.pt)
        .frame(maxWidth: .infinity)
    }

    private typealias L10n = LocalizationConstants.SuperApp.Dashboard.GetStarted.Trading
    var blockedView: some View {
        AlertCard(
            title: L10n.blockedTitle,
            message: L10n.blockedMessage,
            variant: .error,
            isBordered: true,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: L10n.blockedContactSupport,
                        action: {
                            $app.post(event: blockchain.ux.dashboard.trading.is.blocked.contact.support.paragraph.button.primary.tap)
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
        .padding(.horizontal)
        .onAppear {
            $app.post(event: blockchain.ux.dashboard.trading.is.blocked)
        }
        .batch {
            set(blockchain.ux.dashboard.trading.is.blocked.contact.support.paragraph.button.primary.tap.then.emit, to: blockchain.ux.customer.support.show.messenger)
        }
    }

    @State private var supportURL: URL?
    var rejectedView: some View {
        AlertCard(
            title: L10n.weCouldNotVerify,
            message: L10n.unableToVerifyGoToDeFi,
            variant: .warning,
            isBordered: true,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: L10n.blockedContactSupport,
                        action: {
                            $app.post(event: blockchain.ux.dashboard.kyc.is.rejected.contact.support.paragraph.button.small.secondary.tap)
                        }
                    )
                    SmallSecondaryButton(
                        title: L10n.goToDeFi,
                        action: {
                            $app.post(event: blockchain.ux.dashboard.kyc.is.rejected.go.to.DeFi.paragraph.button.small.secondary.tap)
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
        .padding(.horizontal)
        .onAppear {
            $app.post(event: blockchain.ux.dashboard.kyc.is.rejected)
        }
        .bindings {
            subscribe($supportURL, to: blockchain.ux.kyc.is.rejected.support.url)
        }
        .batch {
            set(blockchain.ux.dashboard.kyc.is.rejected.go.to.DeFi.paragraph.button.small.secondary.tap.then.set.session.state, to: [
                [
                    "key": blockchain.app.mode[],
                    "value": "PKW"
                ]
            ])
            if let supportURL {
                set(blockchain.ux.dashboard.kyc.is.rejected.contact.support.paragraph.button.small.secondary.tap.then.enter.into, to: blockchain.ux.web[supportURL])
            }
        }
    }
}

struct DashboardMainBalanceView: View {
    @Binding var info: BalanceInfo?
    var isPercentageHidden: Bool

    /// default values are for redacted placeholder
    var body: some View {
        if let info {
            MoneyValueHeaderView(
                title: info.balance,
                subtitle: {
                    if !isPercentageHidden, let change = info.change, change.isNotZero {
                        HStack(spacing: Spacing.padding1) {
                            Text(info.marketArrow)
                            change.abs()
                            Text(info.changePercentageTitle)
                        }
                        .foregroundColor(info.foregroundColor)
                    }
                }
            )
        } else {
            MoneyValueHeaderView(
                title: .create(major: 100.00, currency: .fiat(.USD)),
                subtitle: { Text("↓ $10.50 (0.15%)") }
            )
            .redacted(reason: .placeholder)
        }
    }
}

extension BalanceInfo {

    var foregroundColor: Color {
        guard let change, change.isNotZero else {
            return .semantic.body
        }
        return change.isPositive ? .semantic.success : .semantic.pinkHighlight
    }

    var changePercentageTitle: String {
        guard let changePercentageValue else { return "0%" }
        return "(\(changePercentageValue.formatted(.percent.precision(.fractionLength(2)))))"
    }

    var marketArrow: String {
        guard let change else { return "→" }
        return change.isNegative ? "↓" : "↑"
    }
}

// MARK: Provider

func provideTradingDashboard(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    TradingDashboardView(
        store: store.scope(
            state: \.tradingState.home,
            action: DashboardContent.Action.tradingHome
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}
