// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

enum DomainCheckoutConfirmationStatus {
    case success
    case error
}

struct DomainCheckoutConfirmationView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.CheckoutConfirmation
    private typealias Accessibility = AccessibilityIdentifiers.CheckoutConfirmation

    private let status: DomainCheckoutConfirmationStatus
    private let domain: SearchDomainResult
    private let completion: () -> Void
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.openURL) private var openURL

    init(
        status: DomainCheckoutConfirmationStatus,
        domain: SearchDomainResult,
        completion: @escaping () -> Void
    ) {
        self.status = status
        self.domain = domain
        self.completion = completion
    }

    var body: some View {
        VStack(spacing: Spacing.padding3) {
            Spacer()
            Icon.globe
                .color(.semantic.primary)
                .frame(width: 54, height: 54)
                .accessibility(identifier: Accessibility.icon)
            Text(String(format: title, domain.domainName))
                .typography(.title3)
                .accessibility(identifier: Accessibility.title)
            Text(description)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
                .accessibility(identifier: Accessibility.description)
            if status == .success {
                SmallMinimalButton(title: LocalizedString.Success.learnMore) {
                    openURL(Constants.SupportURL.learnMoreAboutCryptoDomain)
                }
                .accessibility(identifier: Accessibility.learnMoreButton)
            }
            Spacer()
            PrimaryButton(title: buttonLabel) {
                switch status {
                case .success:
                    completion()
                case .error:
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .accessibility(identifier: Accessibility.okayButton)
        }
        .navigationBarBackButtonHidden(true)
        .multilineTextAlignment(.center)
        .padding([.leading, .trailing, .bottom], Spacing.padding3)
    }

    private var title: String {
        switch status {
        case .success:
            LocalizedString.Success.title
        case .error:
            LocalizedString.Error.title
        }
    }

    private var description: String {
        switch status {
        case .success:
            LocalizedString.Success.description
        case .error:
            LocalizedString.Error.description
        }
    }

    private var buttonLabel: String {
        switch status {
        case .success:
            LocalizedString.Success.okayButton
        case .error:
            LocalizedString.Error.tryAgainButton
        }
    }
}

struct DomainCheckoutConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DomainCheckoutConfirmationView(
            status: .success,
            domain: SearchDomainResult(
                domainName: "example.blockchain",
                domainType: .free,
                domainAvailability: .availableForFree
            ),
            completion: {}
        )
    }
}
