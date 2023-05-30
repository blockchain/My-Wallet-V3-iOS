// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Errors
import MoneyKit
import SwiftUI

struct DexDialog: Hashable {

    struct Action: Hashable {

        let title: String
        let handler: () -> Void

        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }

        static func == (lhs: DexDialog.Action, rhs: DexDialog.Action) -> Bool {
            lhs.title == rhs.title
        }
    }

    var title: String
    var message: String
    var actions: [Action]
    let icon: Icon = Icon.walletSwap
    var status: Icon
}

struct DexDialogView: View {

    private let dialog: DexDialog
    private let overlay: Double = 7.5
    private let dismiss: () -> Void
    
    init(dialog: DexDialog, dismiss: @escaping () -> Void) {
        self.dialog = dialog
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            VStack(spacing: .none) {
                Spacer()
                icon
                content
                Spacer()
            }
            .multilineTextAlignment(.center)
            actions
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
    private var actions: some View {
        VStack(spacing: Spacing.padding1) {
            ForEach(dialog.actions.indexed(), id: \.index) { index, action in
                if index == dialog.actions.startIndex {
                    MinimalButton(
                        title: action.title,
                        isOpaque: true,
                        action: {
                            dismiss()
                            action.handler()
                        }
                    )
                } else {
                    PrimaryButton(
                        title: action.title,
                        action: {
                            dismiss()
                            action.handler()
                        }
                    )
                }
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
            actions: [
                DexDialog.Action(
                    title: "View on Explorer",
                    handler: { print("tap") }
                ),
                DexDialog.Action(
                    title: "Done",
                    handler: { print("tap") }
                )
            ],
            status: .pending
        ),
        DexDialog(
            title: L10n.Execution.InProgress.title,
            message: "",
            actions: [
                DexDialog.Action(
                    title: "View on Explorer",
                    handler: { print("tap") }
                ),
                DexDialog.Action(
                    title: "Done",
                    handler: { print("tap") }
                )
            ],
            status: .pending
        )
    ]
}
