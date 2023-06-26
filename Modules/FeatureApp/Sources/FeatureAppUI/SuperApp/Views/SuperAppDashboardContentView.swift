// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import SwiftUI
import UIKit

struct SuperAppDashboardContentView: View {
    @Binding var currentModeSelection: AppMode
    var isTradingEnabled: Bool

    let store: StoreOf<SuperAppContent>

    init(
        currentModeSelection: Binding<AppMode>,
        isTradingEnabled: Bool,
        store: StoreOf<SuperAppContent>
    ) {
        self._currentModeSelection = currentModeSelection
        self.isTradingEnabled = isTradingEnabled
        self.store = store
    }

    var body: some View {
        ZStack {
            if isTradingEnabled {
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
}
