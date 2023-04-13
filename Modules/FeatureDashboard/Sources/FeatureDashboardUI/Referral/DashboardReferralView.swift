// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import FeatureReferralDomain
import Localization
import SwiftUI

public struct DashboardReferralView: View {
    typealias L10n = LocalizationConstants.Referrals

    @BlockchainApp var app

    @State private var model: Referral?

    public init() {}

    public var body: some View {
        ZStack(alignment: .leading) {
            if let model {
                Group {
                    Color.semantic.primary
                        .frame(height: 87.pt)
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.padding2))
                    AsyncMedia(url: model.announcement?.style?.background?.media?.url ?? "")
                        .resizingMode(.aspectFill)
                        .frame(height: 87.pt)
                    VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                        Text(model.announcement?.title ?? L10n.SettingsScreen.buttonTitle)
                            .typography(.caption1)
                            .foregroundColor(.white)
                        Text(model.announcement?.message ?? "")
                            .typography(.body2)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, Spacing.padding2)
                }
                .onTapGesture {
                    app.post(
                        event: blockchain.ux.referral.details.screen.entry.paragraph.button.secondary.tap,
                        context: [
                            blockchain.ux.referral.details.screen.info: model,
                            blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                        ]
                    )
                }
            } else {
                Spacer().frame(height: 0)
            }
        }
        .bindings {
            subscribe($model, to: blockchain.user.referral.campaign)
        }
        .frame(height: model == nil ? 0.pt : 87.pt)
        .padding(.horizontal, Spacing.padding2)
        .batch(
            .set(
                blockchain.ux.referral.details.screen.entry.paragraph.button.secondary.tap.then.enter.into,
                to: blockchain.ux.referral.details.screen
            )
        )
    }
}
