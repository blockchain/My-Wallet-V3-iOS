// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

struct LockedAccountRow: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let title: String
    let subtitle: String
    let icon: Icon

    var body: some View {
        PrimaryRow(
            title: title,
            subtitle: subtitle,
            leading: {
                icon
                    .color(.semantic.muted)
                    .frame(width: 24)
            },
            trailing: {
                Icon.lockClosed
                    .color(.semantic.muted)
                    .frame(width: 24)
            },
            action: {
                app.post(
                    event: blockchain.ux.asset.account.require.KYC[].ref(to: context),
                    context: context
                )
            }
        )
    }
}

// swiftlint:disable type_name
struct LockedAccountRow_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            LockedAccountRow(
                title: "Blockchain.com Account",
                subtitle: "Buy and Sell Bitcoin",
                icon: .trade
            )
        }
    }
}
