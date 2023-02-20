// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

@MainActor
struct TableRowExamplesView: View {

    @State private var chevron = false
    @State private var toggle = false
    @State private var alert = false

    var icon: some View {
        Icon.placeholder.small()
    }

    var media: some View {
        AsyncMedia(url: "https://www.blockchain.com/static/img/prices/prices-btc.svg")
    }

    var body: some View {
        ScrollView {
            VStack {
                TableRow(
                    title: "Left Title",
                    byline: "Left Byline",
                    footer: {
                        Text("Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.")
                            .typography(.caption1)
                            .foregroundColor(.semantic.text)
                        TagView(text: "Fastest", variant: .success)
                    }
                )
            }
            VStack {
                TableRow(
                    title: "Left Title",
                    byline: "Left Byline"
                )
                TableRow(
                    title: "Left Title",
                    byline: "Left Byline",
                    trailingTitle: "Right Title"
                )
                TableRow(
                    title: "Left Title"
                )
                TableRow(
                    title: "Left Title",
                    trailingTitle: "Right Title"
                )
                TableRow(
                    title: "Left Title",
                    inlineTitleButton: IconButton(
                        icon: .question.circle().micro(),
                        action: { alert = true }
                    ),
                    byline: "Left Byline"
                )
                TableRow(
                    title: "Left Title",
                    byline: "Left Byline",
                    isOn: $toggle
                )
                TableRow(
                    title: "Left Title",
                    byline: "Left Byline",
                    tag: { TagView(text: "Confirmed", variant: .success) }
                )
            }
            VStack {
                TableRow(
                    leading: { icon },
                    title: "Left Title",
                    byline: "Left Byline"
                )
                TableRow(
                    leading: { icon },
                    title: "Left Title",
                    byline: "Left Byline",
                    trailingTitle: "Right Title"
                )
                TableRow(
                    leading: { icon },
                    title: "Left Title"
                )
                TableRow(
                    leading: { icon },
                    title: "Left Title",
                    trailingTitle: "Right Title"
                )
                TableRow(
                    leading: { icon },
                    title: "Left Title",
                    inlineTitleButton: IconButton(
                        icon: .question.circle().micro(),
                        action: { alert = true }
                    ),
                    byline: "Left Byline"
                )
                TableRow(
                    leading: { icon },
                    title: "Left Title",
                    byline: "Left Byline",
                    isOn: $toggle
                )
                TableRow(
                    leading: { icon },
                    title: "Left Title",
                    byline: "Left Byline",
                    tag: { TagView(text: "Confirmed", variant: .success) }
                )
            }
            VStack {
                TableRow(
                    leading: { media },
                    title: "Left Title",
                    byline: "Left Byline"
                )
                TableRow(
                    leading: { media },
                    title: "Left Title",
                    byline: "Left Byline",
                    trailingTitle: "Right Title"
                )
                TableRow(
                    leading: { media },
                    title: "Left Title"
                )
                TableRow(
                    leading: { media },
                    title: "Left Title",
                    trailingTitle: "Right Title"
                )
                TableRow(
                    leading: { media },
                    title: "Left Title",
                    inlineTitleButton: IconButton(
                        icon: .question.circle().micro(),
                        action: { alert = true }
                    ),
                    byline: "Left Byline"
                )
                TableRow(
                    leading: { media },
                    title: "Left Title",
                    byline: "Left Byline",
                    isOn: $toggle
                )
                TableRow(
                    leading: { media },
                    title: "Left Title",
                    byline: "Left Byline",
                    tag: { TagView(text: "Confirmed", variant: .success) }
                )
            }
        }
        .tableRowChevron(chevron)
#if os(iOS)
        .toolbar {
            ToolbarItem(id: "Chevron", placement: .navigationBarTrailing) {
                Toggle(isOn: $chevron, label: EmptyView.init)
            }
        }
        .apply { view in
            if #available(iOS 15.0, *) {
                view.alert("(?)", isPresented: $alert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }
#endif
    }
}

struct TableRowExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        TableRowExamplesView()
    }
}
