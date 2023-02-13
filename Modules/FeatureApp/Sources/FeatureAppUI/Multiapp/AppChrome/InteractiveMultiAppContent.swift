// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureDashboardUI
import SwiftUI

@available(iOS 15.0, *)
struct InteractiveMultiAppContent: View {
    @BlockchainApp var app
    let store: StoreOf<SuperAppContent>
    /// The current selected app mode
    @Binding var currentModeSelection: AppMode
    /// The content offset for the modal sheet
    @Binding var contentOffset: ModalSheetContext
    /// The scroll offset for the inner scroll view, not currently used...
    @Binding var scrollOffset: CGPoint

    @State private var selectedDetent: UISheetPresentationController.Detent.Identifier = AppChromeDetents.collapsed.identifier
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @Binding var isRefreshing: Bool

    @State private var hideBalanceAfterRefresh = false

    var body: some View {
        WithViewStore(store, observe: \.headerState, content: { viewStore in
            MultiAppHeaderView(
                store: store.scope(state: \.headerState, action: SuperAppContent.Action.header),
                currentSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                scrollOffset: $scrollOffset,
                isRefreshing: $isRefreshing
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
            .onChange(of: currentModeSelection, perform: { newValue in
                app.post(value: newValue.rawValue, of: blockchain.app.mode)
            })
            .onChange(of: isRefreshing, perform: { newValue in
                if !newValue {
                    hideBalanceAfterRefresh.toggle()
                }
            })
            .task(id: hideBalanceAfterRefresh) {
                // run initial "animation" and select `semiCollapsed` detent after 3 second
                do {
                    try await Task.sleep(nanoseconds: 3 * 1000000000)
                    if !isRefreshing {
                        let detent: AppChromeDetents = viewStore.state.tradingEnabled ? .semiCollapsed : .expanded
                        selectedDetent = detent.identifier
                    }
                } catch {}
            }
            .refreshable {
                await viewStore.send(.refresh, while: \.isRefreshing)
            }
            .sheet(isPresented: .constant(true), content: {
                MultiAppContentView(
                    selectedDetent: $selectedDetent,
                    content: {
                        ZStack {
                            if viewStore.state.tradingEnabled {
                                DashboardContentView(
                                    store: store.scope(
                                        state: \.trading,
                                        action: SuperAppContent.Action.trading
                                    )
                                )
                                .opacity(currentModeSelection.isTrading ? 1.0 : 0.0)
                            }
                            DashboardContentView(
                                store: store.scope(
                                    state: \.defi,
                                    action: SuperAppContent.Action.defi
                                )
                            )
                            .opacity(currentModeSelection.isDefi ? 1.0 : 0.0)
                        }
                    }
                )
                .background(
                    Color.semantic.light
                )
                .frame(maxWidth: .infinity)
                .presentationDetents(
                    selectedDetent: $selectedDetent,
                    largestUndimmedDetentIdentifier: largestUndimmedDetentIdentifier(isTradingEnabled: viewStore.state.tradingEnabled),
                    limitDetents: .constant(!viewStore.tradingEnabled),
                    modalOffset: $contentOffset
                )
            })
        })
    }

    private func largestUndimmedDetentIdentifier(
        isTradingEnabled: Bool
    ) -> UISheetPresentationController.Detent.Identifier {
        isTradingEnabled ? AppChromeDetents.semiCollapsed.identifier : AppChromeDetents.expanded.identifier
    }
}
