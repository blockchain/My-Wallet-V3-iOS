// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import PlatformKit
import SwiftUI

private typealias LocalizedStrings = LocalizationConstants.KYC
private typealias LimitsFeatureStrings = LocalizedStrings.LimitsOverview.Feature

extension KYC.Tier {

    var accentColor: Color {
        isVerified ? .semantic.primary : .semantic.silver
    }

    var limitsTitle: String {
        guard isVerified else {
            return LimitsFeatureStrings.silverLimitsTitle
        }
        return LimitsFeatureStrings.goldLimitsTitle
    }

    var limitsMessage: String {
        guard isVerified else {
            return LimitsFeatureStrings.silverLimitsMessage
        }
        return LimitsFeatureStrings.goldLimitsMessage
    }

    var limitsDetails: String {
        guard isVerified else {
            return LimitsFeatureStrings.silverLimitsDetails
        }
        return LimitsFeatureStrings.goldLimitsDetails
    }

    var limitsNote: String? {
        guard isVerified else {
            return nil
        }
        return LimitsFeatureStrings.silverLimitsNote
    }
}

struct TierTradeLimitCell: View {

    let tier: KYC.Tier

    var body: some View {
        HStack(spacing: Spacing.padding2) {
            Image("icon-verified", bundle: .module)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .accentColor(tier.accentColor)
                .foregroundColor(tier.accentColor)
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(tier.limitsTitle)
                    .typography(.body2)
                if let note = tier.limitsNote {
                    Text(note)
                        .typography(.caption1)
                }
            }
            Spacer()
            TagView(text: LocalizedStrings.accountApprovedBadge, variant: .success)
        }
        .padding(Spacing.padding3)
        .frame(maxWidth: .infinity, minHeight: 80)
    }
}

struct TierTradeLimitCell_Previews: PreviewProvider {

    static var previews: some View {
        VStack(spacing: Spacing.baseline) {
            TierTradeLimitCell(tier: .verified)
        }
    }
}
