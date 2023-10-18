// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureDashboardUI
import FeatureProductsDomain
import SwiftUI

struct SuperAppContentViewSmallDevice: View {
    @Environment(\.isSmallDevice) var isSmallDevice
    @Environment(\.colorScheme) var colorScheme

    @BlockchainApp var app
    let store: StoreOf<SuperAppContent>
    /// The current selected app mode
    @Binding var currentModeSelection: AppMode
    /// The content offset for the modal sheet
    @Binding var contentOffset: ModalSheetContext

    @State private var isDeFiOnly = true
    @State private var isExternalTradingEnabled = false
    private var isTradingEnabled: Bool { !isDeFiOnly }

    /// `True` when a pull to refresh is triggered, otherwise `false`
    @Binding var isRefreshing: Bool
    @State var isPullToRefreshEnabled: Bool = false

    @State private var headerFrame: CGRect = .zero

    var body: some View {
        WithViewStore(store, observe: \.headerState, content: { viewStore in
            ZStack(alignment: .top) {
                SuperAppHeaderView(
                    store: store.scope(state: \.headerState, action: SuperAppContent.Action.header),
                    currentSelection: $currentModeSelection,
                    contentOffset: $contentOffset,
                    isRefreshing: $isRefreshing,
                    headerFrame: $headerFrame,
                    isPullToRefreshEnabled: $isPullToRefreshEnabled
                )
                .onAppear {
                    viewStore.send(.onAppear)
                    if !isPullToRefreshEnabled {
                        viewStore.send(.refresh)
                    }
                }
                .onDisappear {
                    viewStore.send(.onDisappear)
                }
                .onAppear {
                    update(colorScheme: colorScheme)
                }
                .onChange(of: currentModeSelection) { newValue in
                    app.post(value: newValue.rawValue, of: blockchain.app.mode)
                }
                .bindings(
                    managing: { update in
                        if case .didSynchronize = update, isDeFiOnly {
                            currentModeSelection = .pkw
                        }
                    },
                    {
                        subscribe($isPullToRefreshEnabled, to: blockchain.ux.app.pull.to.refresh.is.enabled)
                        subscribe($currentModeSelection.removeDuplicates().animation(), to: blockchain.app.mode)
                        subscribe($isDeFiOnly, to: blockchain.app.is.DeFi.only)
                        subscribe($isExternalTradingEnabled, to: blockchain.api.nabu.gateway.user.products.product["USE_EXTERNAL_TRADING_ACCOUNT"].is.eligible)
                    }
                )
                .onChange(of: isTradingEnabled) { newValue in
                    if currentModeSelection == .trading, newValue == false {
                        currentModeSelection = .pkw
                    }
                }
                .refreshable {
                    if isPullToRefreshEnabled {
                        await viewStore.send(.refresh, while: \.isRefreshing)
                    }
                }
                SuperAppDashboardContentView(
                    currentModeSelection: $currentModeSelection,
                    isTradingEnabled: isTradingEnabled,
                    isExternalTradingEnabled: isExternalTradingEnabled,
                    store: store
                )
                .cornerRadius(Spacing.padding3, corners: [.topLeft, .topRight])
                .padding(.top, headerFrame.height)
                .introspectViewController(customize: { controller in
                    controller.view.backgroundColor = .clear
                })
                .frame(maxWidth: .infinity)
                .background(
                    Color.clear
                )
            }
        })
    }

    private func update(colorScheme: ColorScheme) {
        let interface = blockchain.ui.device.settings.interface
        app.state.transaction { state in
            state.set(interface.style, to: colorScheme == .dark ? interface.style.dark[] : interface.style.light[])
            state.set(interface.is.dark, to: colorScheme == .dark)
            state.set(interface.is.light, to: colorScheme == .light)
        }
    }

}
