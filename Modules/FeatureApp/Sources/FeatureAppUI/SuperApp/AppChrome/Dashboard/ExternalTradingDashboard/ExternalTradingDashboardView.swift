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
import FeatureExternalTradingMigrationDomain
import FeatureQuickActions
import FeatureTopMoversCryptoUI
import FeatureTransactionUI
import Localization
import MoneyKit
import SwiftUI

struct ExternalTradingDashboardView: View {
    private typealias L10n = LocalizationConstants.SuperApp.Dashboard.GetStarted.Trading

    @BlockchainApp var app
    let store: StoreOf<ExternalTradingDashboard>
    @ObservedObject var viewStore: ViewStore<ExternalTradingDashboardView.ViewState, ExternalTradingDashboard.Action>

    @State private var scrollOffset: CGPoint = .zero
    @State private var isBlocked = false
    @State private var kycState: Tag = blockchain.user.account.kyc.state.none[]
    var isRejected: Bool { kycState == blockchain.user.account.kyc.state.rejected[] }
    @StateObject private var onboarding = CustodialOnboardingService()

    @State private var externalTradingMigrationState: Tag?
    var externalTradingMigrationIsPending: Bool {
        guard let externalTradingMigrationState else {
            return false
        }
        return externalTradingMigrationState == blockchain.api.nabu.gateway.user.external.brokerage.migration.state.pending[]
    }

    struct ViewState: Equatable {
        @BindingViewState var migrationInfo: ExternalTradingMigrationInfo?
        let balance: BalanceInfo?
        let getStartedBuyCryptoAmmounts: [TradingGetStartedAmmountValue]
        var isZeroBalance: Bool { balance?.balance.isZero ?? false }
        var isBalanceLoaded: Bool { balance != nil }

        init(state: BindingViewStore<ExternalTradingDashboard.State>) {
            self.balance = state.tradingBalance
            self.getStartedBuyCryptoAmmounts = state.getStartedBuyCryptoAmmounts
            self._migrationInfo = state.$migrationInfo
        }
    }

    init(store: StoreOf<ExternalTradingDashboard>) {
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
            subscribe(
                $isBlocked,
                to: blockchain.user.is.blocked
            )
            subscribe(
                $externalTradingMigrationState,
                to: blockchain.api.nabu.gateway.user.external.brokerage.migration.state
            )
            subscribe(
                $kycState,
                to: blockchain.user.account.kyc.state
            )
        }
        .onAppear {
            onboarding.request()
            $app.post(event: blockchain.ux.home.dashboard)
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
                    QuickActionsView(
                        tag: blockchain.ux.user.custodial.external.brokerage.dashboard.quick.action
                    )
                }
            }

            if isBlocked {
                blockedView
            }

            if externalTradingMigrationIsPending {
                externalTradingMigrationInProgressView
            }

            if !viewStore.isZeroBalance {
                if isRejected {
                    rejectedView
                } else {
                    DashboardAssetSectionView(
                        store: store.scope(
                            state: \.assetsState,
                            action: ExternalTradingDashboard.Action.assetsAction
                        )
                    )
                }
            }

            DashboardActivitySectionView(
                store: store.scope(state: \.activityState, action: ExternalTradingDashboard.Action.activityAction)
            )
        }
        .scrollOffset($scrollOffset)
        .task {
            await viewStore.send(.prepare).finish()
        }
        .padding(.bottom, 72.pt)
        .frame(maxWidth: .infinity)
    }

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

    var externalTradingMigrationInProgressView: some View {
        AlertCard(
            title: L10n.bakktMigrationInProgressTitle,
            message: L10n.bakktMigrationMessage,
            variant: .default,
            isBordered: true
        )
        .padding(.horizontal)
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
                    "value": "TRADING"
                ]
            ])
            if let supportURL {
                set(blockchain.ux.dashboard.kyc.is.rejected.contact.support.paragraph.button.small.secondary.tap.then.enter.into, to: blockchain.ux.web[supportURL])
            }
        }
    }
}

// MARK: Provider

func provideExternalTradingDashboard(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    ExternalTradingDashboardView(
        store: store.scope(
            state: \.externalTradingState.home,
            action: DashboardContent.Action.externalTradingHome
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}

func provideExternalTradingPricesTab(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    PricesSceneView(
        store: store.scope(
            state: \.externalTradingState.prices,
            action: DashboardContent.Action.externalTradingPrices
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}
