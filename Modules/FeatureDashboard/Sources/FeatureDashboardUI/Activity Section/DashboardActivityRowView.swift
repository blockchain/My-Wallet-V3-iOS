// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation
import SwiftUI
import UnifiedActivityDomain
import UnifiedActivityUI

public struct DashboardActivityRowView: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    let store: StoreOf<DashboardActivityRow>

    public init(store: StoreOf<DashboardActivityRow>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
                ActivityRow(activityEntry: viewStore.activity, action: {
                    app.post(event: blockchain.ux.activity.detail[viewStore.activity.id].entry.paragraph.row.tap, context: context + [
                        blockchain.ux.activity.detail.model: viewStore.activity
                    ])
                })
                if viewStore.isLastRow == false {
                    Divider()
                        .foregroundColor(.WalletSemantic.light)
                }
            }
            .batch(
                .set(blockchain.ux.activity.detail.entry.paragraph.row.tap.then.enter.into, to: blockchain.ux.activity.detail[viewStore.activity.id])
            )
        }
    }
}
