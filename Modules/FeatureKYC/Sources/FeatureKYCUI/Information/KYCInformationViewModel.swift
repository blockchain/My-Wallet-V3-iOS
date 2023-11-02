// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization
import PlatformKit
import UIKit

struct KYCInformationViewModel {
    let image: UIImage?
    let title: String?
    let subtitle: String?
    let description: String?
    let bottomDescriptionTitle: String?
    let bottomDescription: String?
    let buttonTitle: String?

    init(
        image: UIImage?,
        title: String?,
        subtitle: String?,
        description: String?,
        bottomDescriptionTitle: String? = nil,
        bottomDescription: String? = nil,
        buttonTitle: String?
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.bottomDescriptionTitle = bottomDescriptionTitle
        self.bottomDescription = bottomDescription
        self.buttonTitle = buttonTitle
    }
}

struct KYCInformationViewConfig {
    let isPrimaryButtonEnabled: Bool
}

extension KYCInformationViewModel {
    static func createForUnsupportedCountry(_ country: CountryData) -> KYCInformationViewModel {
        KYCInformationViewModel(
            image: UIImage(named: "Welcome", in: .featureKYCUI, compatibleWith: nil),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, country.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedCountryDescription, country.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable
        )
    }

    static func createForUnsupportedState(_ state: KYCState) -> KYCInformationViewModel {
        KYCInformationViewModel(
            image: UIImage(named: "Welcome", in: .featureKYCUI, compatibleWith: nil),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, state.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedStateDescription, state.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable
        )
    }

    static func create(
        for accountStatus: KYC.AccountStatus,
        isReceivingAirdrop: Bool = false
    ) -> KYCInformationViewModel {
        switch accountStatus {
        case .approved:
            KYCInformationViewModel(
                image: UIImage(named: "AccountApproved", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.accountApproved,
                subtitle: nil,
                description: LocalizationConstants.KYC.accountApprovedDescription,
                buttonTitle: LocalizationConstants.KYC.getStarted
            )
        case .expired, .failed:
            KYCInformationViewModel(
                image: UIImage(named: "AccountFailed", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationFailed,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationFailedDescription,
                buttonTitle: nil
            )
        case .pending:
            createViewModelForPendingStatus(isReceivingAirdrop: isReceivingAirdrop)
        case .underReview:
            KYCInformationViewModel(
                image: UIImage(named: "AccountInReview", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationSubmitted,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationSubmittedDescription,
                bottomDescriptionTitle: LocalizationConstants.KYC.whatHappensNext,
                bottomDescription: LocalizationConstants.KYC.onceYourApplicationIsApproved,
                buttonTitle: nil
            )
        case .none:
            KYCInformationViewModel(
                image: nil,
                title: nil,
                subtitle: nil,
                description: nil,
                buttonTitle: nil
            )
        }
    }

    // MARK: - Private

    private static func createViewModelForPendingStatus(isReceivingAirdrop: Bool) -> KYCInformationViewModel {
        if isReceivingAirdrop {
            KYCInformationViewModel(
                image: UIImage(named: "Icon-Verified-Large", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationInProgress,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationInProgressDescriptionAirdrop,
                buttonTitle: LocalizationConstants.KYC.notifyMe
            )
        } else {
            KYCInformationViewModel(
                image: UIImage(named: "AccountInReview", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationSubmitted,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationSubmittedDescription,
                bottomDescriptionTitle: LocalizationConstants.KYC.whatHappensNext,
                bottomDescription: LocalizationConstants.KYC.onceYourApplicationIsApproved,
                buttonTitle: LocalizationConstants.KYC.ok
            )
        }
    }
}

extension KYCInformationViewConfig {
    static let defaultConfig = KYCInformationViewConfig(
        isPrimaryButtonEnabled: false
    )

    static func create(for accountStatus: KYC.AccountStatus, isReceivingAirdrop: Bool = false) -> KYCInformationViewConfig {
        let isPrimaryButtonEnabled: Bool = switch accountStatus {
        case .approved:
            true
        case .failed, .expired, .none:
            false
        case .pending:
            true
        case .underReview:
            true
        }
        return KYCInformationViewConfig(
            isPrimaryButtonEnabled: isPrimaryButtonEnabled
        )
    }
}
