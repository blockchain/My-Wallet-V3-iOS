import BlockchainUI
import SwiftUI

struct WarningView: View {

    @BlockchainApp var app

    @State private var dismissed: [UX.Dialog] = []

    let warning = blockchain.ux.payment.method.warning
    let dialogs: [UX.Dialog]

    init(_ dialogs: [UX.Dialog]) {
        self.dialogs = dialogs
    }

    var body: some View {
        if dismissed.count == dialogs.count {
            EmptyView()
        } else {
            Carousel(dialogs.indexed(), id: \.element, maxVisible: 1) { i, dialog in
                let dialogId = dialog.id ?? i.description
                if dismissed.doesNotContain(dialog) {
                    AlertCard(
                        title: dialog.title,
                        message: dialog.message,
                        variant: AlertCardVariant(
                            titleColor: .semantic.title,
                            borderColor: dialog.style?.foreground?.color?.swiftUI ?? .semantic.warning
                        ),
                        isBordered: true,
                        backgroundColor: dialog.style?.background?.color?.swiftUI ?? .semantic.light,
                        footer: {
                            if let actions = dialog.actions {
                                HStack(spacing: 8.pt) {
                                    ForEach(actions.indexed(), id: \.element) { index, action in
                                        let actionId = action.url?.absoluteString ?? index.description
                                        let tap = warning[dialogId].action[actionId].paragraph.button.small.minimal.tap
                                        SmallMinimalButton(title: action.title) {
                                            $app.post(event: tap)
                                        }
                                        .batch(.set(tap.then.launch.url, to: action.url))
                                    }
                                }
                            }
                        },
                        onCloseTapped: {
                            withAnimation {
                                dismissed.append(dialog)
                            }
                        }
                    )
                    .post(lifecycleOf: warning[dialogId].paragraph.row)
                    .aspectRatio(3 / 1, contentMode: .fit)
                }
            }
        }
    }
}
