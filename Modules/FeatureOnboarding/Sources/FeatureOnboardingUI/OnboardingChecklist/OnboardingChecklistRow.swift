// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import UIComponentsKit

struct OnboardingChecklistRow: View {

    enum Status {
        case incomplete
        case pending
        case complete
    }

    let item: OnboardingChecklist.Item
    let status: Status

    var body: some View {
        PrimaryRow(
            title: item.title,
            subtitle: status == .pending ? item.pendingDetail : item.detail,
            leading: {
                item.icon
                    .color(item.accentColor)
                    .frame(width: 20, height: 20)
            },
            trailing: {
                if status == .complete {
                    Icon.checkCircle
                        .color(.semantic.success)
                        .frame(width: 24, height: 24)
                } else if status == .pending {
                    ProgressView(value: 0.25)
                        .progressViewStyle(IndeterminateProgressStyle())
                        .frame(width: 24, height: 24)
                } else {
                    Icon.chevronRight
                        .color(item.accentColor)
                        .frame(width: 24, height: 24)
                }
            }
        )
        .padding(2) // to make content fit within rounded corners
    }
}

struct OnboardingRow_Previews: PreviewProvider {

    static var previews: some View {
        VStack(spacing: Spacing.padding1) {
            OnboardingChecklistRow(item: .verifyIdentity, status: .incomplete)
            OnboardingChecklistRow(item: .linkPaymentMethod, status: .pending)
            OnboardingChecklistRow(item: .buyCrypto, status: .complete)
        }
        .padding()
    }
}
