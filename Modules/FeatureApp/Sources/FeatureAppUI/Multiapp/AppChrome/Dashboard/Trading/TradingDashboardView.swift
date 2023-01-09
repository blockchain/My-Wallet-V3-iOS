// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureDashboardUI
import SwiftUI

@available(iOS 15, *)
struct TradingDashboardView: View {
    @BlockchainApp var app

    let store: StoreOf<TradingDashboard>

    @State var scrollOffset: CGFloat = 0
    @StateObject var scrollViewObserver = ScrollViewOffsetObserver()

    struct ViewState: Equatable {
        let actions: FrequentActions
        let balance: BalanceInfo?
        init(state: TradingDashboard.State) {
            self.actions = state.frequentActions
            self.balance = state.tradingBalance
        }
    }

    init(store: StoreOf<TradingDashboard>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init
        ) { viewStore in
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.padding4) {
                    DashboardMainBalanceView(
                        info: .constant(viewStore.balance)
                    )
                    .padding([.top], Spacing.padding3)

                    FrequentActionsView(
                        actions: viewStore.actions
                    )
                    DashboardAssetSectionView(
                        store: self.store.scope(
                            state: \.assetsState,
                            action: TradingDashboard.Action.assetsAction
                        )
                    )

                    DashboardActivitySectionView(
                        store: self.store.scope(state: \.activityState, action: TradingDashboard.Action.activityAction)
                    )

                    DashboardHelpSectionView()
                }
                .findScrollView { scrollView in
                    scrollViewObserver.didScroll = { offset in
                        DispatchQueue.main.async {
                            $scrollOffset.wrappedValue = offset.y
                        }
                    }
                    scrollView.delegate = scrollViewObserver
                }
                .task {
                    await viewStore.send(.prepare).finish()
                }
                .padding(.bottom, 72.pt)
                .frame(maxWidth: .infinity)
            }
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                title: {
                    Text(viewStore.balance?.balanceTitle ?? "")
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                },
                trailing: { [app] in dashboardTrailingItem(app: app) },
                titleShouldFollowScroll: true,
                titleExtraOffset: Spacing.padding3,
                scrollOffset: $scrollOffset
            )
            .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
        }
    }
 }

@available(iOS 15, *)
struct DashboardMainBalanceView: View {
    @Binding var info: BalanceInfo?

    var contentUnavailable: Bool {
        guard let info else {
            return false
        }
        return info.contentUnavailable
    }

    /// default values are for redacted placeholder
    var body: some View {
        VStack(spacing: Spacing.padding1) {
            Text(info?.balanceTitle ?? "$100.000")
                .typography(.title1)
                .foregroundColor(.semantic.title)
            HStack(spacing: Spacing.padding1) {
                Group {
                    Text(info?.marketArrow ?? "↓")
                    Text(info?.changeTitle ?? "$10.50")
                    Text(info?.changePercentageTitle ?? "(0.15%)")
                }
                .typography(.paragraph2)
                .foregroundColor(info?.foregroundColor ?? .semantic.muted)
            }
            .opacity(contentUnavailable ? 0 : 1)
        }
        .redacted(reason: info == nil ? .placeholder : [])
    }
}

@available(iOS 15.0, *)
extension BalanceInfo {
    var balanceTitle: String {
        balance.toDisplayString(includeSymbol: true)
    }

    var contentUnavailable: Bool {
        change == nil
    }

    var foregroundColor: Color {
        guard let change, change.isNotZero else {
            return .semantic.body
        }
        return change.isPositive ? .semantic.success : .semantic.pinkHighlight
    }

    var changeTitle: String {
        guard let change, change.isNotZero else {
            return ""
        }
        return change.toDisplayString(includeSymbol: true)
    }

    var changePercentageTitle: String {
        guard let changePercentageValue else {
            return ""
        }
        return "(\(changePercentageValue.formatted(.percent.precision(.fractionLength(2)))))"
    }

    var marketArrow: String {
        guard let change, change.isNotZero else {
            return ""
        }
        return change.isNegative ? "↓" : "↑"
    }
}

// MARK: Provider

@available(iOS 15, *)
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
