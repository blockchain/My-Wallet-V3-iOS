// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import SwiftUI

// MARK: - ClaimBenefitsView

struct ClaimBenefitsView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.ClaimBenefits
    private typealias Accessibility = AccessibilityIdentifiers.Benefits

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: Spacing.padding3) {
                    benefitsHeader
                        .padding([.leading, .trailing], Spacing.padding3)
                    benefitsList
                    Spacer()
                    PrimaryButton(title: LocalizedString.claimButton) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding([.leading, .trailing, .bottom], Spacing.padding3)
                    .accessibility(identifier: Accessibility.ctaButton)
                }
                .navigationBarTitleDisplayMode(.inline)
                .primaryNavigation(trailing: { closeButton })
            }
            .frame(height: geometry.size.height)
        }
    }

    private var closeButton: some View {
        Button(
            action: {
                presentationMode.wrappedValue.dismiss()
            },
            label: {
                Icon
                    .close
                    .color(.semantic.muted)
                    .circle(backgroundColor: .semantic.light)
                    .frame(width: 24, height: 24)
            }
        )
    }

    private var benefitsHeader: some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            Text(LocalizedString.Header.title)
                .typography(.title3)
                .accessibility(identifier: Accessibility.headerTitle)
            Text(LocalizedString.Header.description)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
                .multilineTextAlignment(.center)
                .accessibility(identifier: Accessibility.headerDescription)
        }
    }

    private var benefitsList: some View {
        VStack(alignment: .center, spacing: 10) {
            PrimaryRow(
                title: LocalizedString.BenefitsList.SimplifyTransaction.title,
                subtitle: LocalizedString.BenefitsList.SimplifyTransaction.description,
                leading: {
                    Icon.flashOnFilled
                        .color(.semantic.primary)
                        .frame(width: 24, height: 24)
                },
                trailing: { EmptyView() }
            )
            PrimaryRow(
                title: LocalizedString.BenefitsList.MultiNetwork.title,
                subtitle: LocalizedString.BenefitsList.MultiNetwork.description,
                leading: {
                    Icon.sell
                        .color(.semantic.primary)
                        .frame(width: 24, height: 24)
                },
                trailing: { EmptyView() }
            )
            PrimaryRow(
                title: LocalizedString.BenefitsList.Ownership.title,
                subtitle: LocalizedString.BenefitsList.Ownership.description,
                leading: {
                    Icon.verified
                        .color(.semantic.primary)
                        .frame(width: 24, height: 24)
                },
                trailing: { EmptyView() }
            )
            PrimaryRow(
                title: LocalizedString.BenefitsList.MuchMore.title,
                subtitle: LocalizedString.BenefitsList.MuchMore.description,
                leading: {
                    Icon.listBullets
                        .color(.semantic.primary)
                        .frame(width: 24, height: 24)
                },
                trailing: { EmptyView() }
            )
        }
        .accessibility(identifier: Accessibility.benefitsList)
    }
}

struct ClaimBenefitsView_Previews: PreviewProvider {
    static var previews: some View {
        ClaimBenefitsView()
    }
}
