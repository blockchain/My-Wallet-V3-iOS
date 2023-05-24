// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Errors
import MoneyKit
import SwiftUI

@MainActor
struct PendingTransactionView: View {

    let store: StoreOf<PendingTransaction>
    @ObservedObject var viewStore: ViewStore<PendingTransaction.State, PendingTransaction.Action>
    private let dismiss: () -> Void

    init(store: StoreOf<PendingTransaction>, dismiss: @escaping () -> Void) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.dismiss = dismiss
    }

    var body: some View {
        switch viewStore.status {
        case .error(let error):
            ErrorView(ux: error)
                .primaryNavigation(
                    title: nil,
                    trailing: { closeButton }
                )
        case .inProgress(let dialog):
            DexDialogView(dialog: dialog)
                .navigationBarBackButtonHidden(true)
                .primaryNavigation()
        case .success(let dialog, let currency):
            ConfettiCannonView(confetti(currency: currency)) { action in
                DexDialogView(dialog: dialog)
                    .onTapGesture(perform: action)
            }
            .navigationBarBackButtonHidden(true)
            .primaryNavigation(
                title: nil,
                trailing: { closeButton }
            )
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(
            action: { dismiss() },
            label: {
                Icon
                    .closev2
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 24, height: 24)
            }
        )
    }

    private func confetti(currency: CryptoCurrency) -> ConfettiConfiguration {
        ConfettiConfiguration(
            confetti: [
                .icon(.blockchain.color(.semantic.primary)),
                .view(currency.logo()),
                .view(Rectangle().frame(width: 5.pt).foregroundColor(.semantic.success)),
                .view(Rectangle().frame(width: 5.pt).foregroundColor(.semantic.gold))
            ]
        )
    }
}
