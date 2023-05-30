// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Errors
import MoneyKit
import SwiftUI

@MainActor
struct PendingTransactionView: View {

    let state: PendingTransaction.State
    private let dismiss: () -> Void

    init(state: PendingTransaction.State, dismiss: @escaping () -> Void) {
        self.state = state
        self.dismiss = dismiss
    }

    var body: some View {
        switch state.status {
        case .error(let error):
            ErrorView(ux: error)
                .primaryNavigation(
                    title: nil,
                    trailing: { closeButton }
                )
        case .inProgress(let dialog):
            DexDialogView(dialog: dialog, dismiss: dismiss)
                .navigationBarBackButtonHidden(true)
                .primaryNavigation()
        case .success(let dialog, let currency):
            ConfettiCannonView(confetti(currency: currency)) { action in
                DexDialogView(dialog: dialog, dismiss: dismiss)
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
