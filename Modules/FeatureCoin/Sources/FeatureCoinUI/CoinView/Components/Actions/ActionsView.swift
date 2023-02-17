// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

struct ActionsView: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    var actions: [ButtonAction]

    var body: some View {
        HStack(spacing: Spacing.padding1) {
            ForEach(actions, id: \.event) { action in
                let isLastItem = (action.event == actions.last?.event && actions.count > 2)
                if isLastItem {
                    Button {
                        app.post(event: action.event[].ref(to: context), context: context)
                    } label: {
                        action
                            .icon
                            .micro()
                            .color(.semantic.title)
                    }
                    .frame(width: 56, height: 56)
                    .background(Color.white)
                    .clipShape(Circle())
                } else {
                    MinimalButton(
                        title: action.title,
                        foregroundColor: .WalletSemantic.title,
                        leadingView: { action
                            .icon
                            .color(.WalletSemantic.title)
                            .frame(width: 14, height: 14)
                        },
                        action: {
                            app.post(event: action.event[].ref(to: context), context: context)
                        }
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.padding2)
    }
}

struct ActionsView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsView(actions: [.sell(), .swap()])
    }
}
