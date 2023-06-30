// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Errors
import MoneyKit
import SwiftUI

struct DexDialog: Hashable {

    struct Button: Hashable {

        enum Action {
            case dismiss
            case openURL(URL?)
        }

        let title: String
        let action: Action

        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }

        static func == (lhs: DexDialog.Button, rhs: DexDialog.Button) -> Bool {
            lhs.title == rhs.title
        }
    }

    var title: String
    var message: String = ""
    var buttons: [Button] = []
    let icon: Icon = Icon.walletSwap
    var status: Icon
}

struct DexDialogView: View {

    @Environment(\.openURL) var openURL
    private let dialog: DexDialog
    private let overlay: Double = 7.5
    private let dismiss: () -> Void

    init(dialog: DexDialog, dismiss: @escaping () -> Void) {
        self.dialog = dialog
        self.dismiss = dismiss
    }

    @ViewBuilder
    var body: some View {
        VStack {
            VStack(spacing: .none) {
                Spacer()
                icon
                content
                Spacer()
            }
            .multilineTextAlignment(.center)
            buttons
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
    }

    @ViewBuilder
    private var icon: some View {
        dialog.icon
            .with(length: 88.pt)
            .color(.semantic.title)
            .circle(backgroundColor: .semantic.background)
            .padding((overlay / 2.d).i.vmin)
            .overlay(iconOverlay, alignment: .bottomTrailing)
    }

    @ViewBuilder
    private var iconOverlay: some View {
        ZStack {
            Circle()
                .foregroundColor(.semantic.light)
                .scaleEffect(1.2)
            Group {
                dialog
                    .status
                    .color(.semantic.muted)
                    .with(length: 44.pt)
            }
            .scaleEffect(1)
        }
        .frame(
            width: overlay.vmin,
            height: overlay.vmin
        )
        .offset(x: -overlay, y: -overlay)
    }

    @ViewBuilder
    private var content: some View {
        if dialog.title.isNotEmpty {
            Text(rich: dialog.title)
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.bottom, Spacing.padding1.pt)
        }
        if dialog.message.isNotEmpty {
            Text(rich: dialog.message)
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.bottom, Spacing.padding2.pt)
        }
    }

    @ViewBuilder
    private var buttons: some View {
        VStack(spacing: Spacing.padding1) {
            ForEach(dialog.buttons.indexed(), id: \.index) { index, button in
                if index == dialog.buttons.startIndex {
                    MinimalButton(
                        title: button.title,
                        isOpaque: true,
                        action: { execute(button) }
                    )
                } else {
                    PrimaryButton(
                        title: button.title,
                        action: { execute(button) }
                    )
                }
            }
        }
    }

    private func execute(_ button: DexDialog.Button) {
        switch button.action {
        case .dismiss:
            dismiss()
        case .openURL(let url):
            dismiss()
            if let url {
                openURL(url)
            }
        }
    }
}

struct DexDialogView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(dialogs.indexed(), id: \.index) { dialog in
            DexDialogView(dialog: dialog.element, dismiss: { print("dismiss") })
        }
    }

    static var dialogs: [DexDialog] = [
        DexDialog(
            title: L10n.Execution.Success.title,
            message: L10n.Execution.Success.body,
            buttons: [
                DexDialog.Button(
                    title: "View on Explorer",
                    action: .dismiss
                ),
                DexDialog.Button(
                    title: "Done",
                    action: .dismiss
                )
            ],
            status: .pending
        ),
        DexDialog(
            title: L10n.Execution.InProgress.title,
            message: "",
            buttons: [
                DexDialog.Button(
                    title: "View on Explorer",
                    action: .dismiss
                ),
                DexDialog.Button(
                    title: "Done",
                    action: .dismiss
                )
            ],
            status: .pending
        )
    ]
}
