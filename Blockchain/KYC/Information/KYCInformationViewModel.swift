//
//  KYCInformationViewModel.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCInformationViewModel {
    let image: UIImage?
    let title: String?
    let subtitle: String?
    let description: String?
    let buttonTitle: String?
    var badge: String?
}

struct KYCInformationViewConfig {
    let titleColor: UIColor
    let isPrimaryButtonEnabled: Bool
}

extension KYCInformationViewModel {
    static func createForUnsupportedCountry(_ country: KYCCountry) -> KYCInformationViewModel {
        return KYCInformationViewModel(
            image: #imageLiteral(resourceName: "Welcome"),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, country.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedCountryDescription, country.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable,
            badge: nil
        )
    }

    static func createForUnsupportedState(_ state: KYCState) -> KYCInformationViewModel {
        return KYCInformationViewModel(
            image: #imageLiteral(resourceName: "Welcome"),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, state.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedStateDescription, state.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable,
            badge: nil
        )
    }

    static func create(for accountStatus: KYCAccountStatus) -> KYCInformationViewModel {
        switch accountStatus {
        case .approved:
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountApproved"),
                title: LocalizationConstants.KYC.accountApproved,
                subtitle: nil,
                description: LocalizationConstants.KYC.accountApprovedDescription,
                buttonTitle: LocalizationConstants.KYC.getStarted,
                badge: LocalizationConstants.KYC.accounVerifiedBadge
            )
        case .expired, .failed:
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountFailed"),
                title: LocalizationConstants.KYC.verificationFailed,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationFailedDescription,
                buttonTitle: nil,
                badge: LocalizationConstants.KYC.verificationFailedBadge
            )
        case .pending:
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountInReview"),
                title: LocalizationConstants.KYC.verificationInProgress,
                subtitle: LocalizationConstants.KYC.whatHappensNext,
                description: LocalizationConstants.KYC.verificationInProgressDescription,
                buttonTitle: LocalizationConstants.KYC.notifyMe,
                badge: LocalizationConstants.KYC.accountUnderReviewBadge
            )
        case .underReview:
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountInReview"),
                title: LocalizationConstants.KYC.verificationUnderReview,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationUnderReviewDescription,
                buttonTitle: nil,
                badge: LocalizationConstants.KYC.accountUnderReviewBadge
            )
        case .none:
            return KYCInformationViewModel(
                image: nil,
                title: nil,
                subtitle: nil,
                description: nil,
                buttonTitle: nil,
                badge: LocalizationConstants.KYC.accountUnverifiedBadge
            )
        }
    }
}

extension KYCInformationViewConfig {
    static let defaultConfig: KYCInformationViewConfig = KYCInformationViewConfig(
        titleColor: UIColor.gray5,
        isPrimaryButtonEnabled: false
    )

    static func create(for accountStatus: KYCAccountStatus) -> KYCInformationViewConfig {
        let titleColor: UIColor
        let isPrimaryButtonEnabled: Bool
        switch accountStatus {
        case .approved:
            titleColor = UIColor.green
            isPrimaryButtonEnabled = true
        case .failed, .expired, .none:
            titleColor = UIColor.error
            isPrimaryButtonEnabled = accountStatus != .failed
        case .pending:
            titleColor = UIColor.orange
            isPrimaryButtonEnabled = !UIApplication.shared.isRegisteredForRemoteNotifications
        case .underReview:
            titleColor = .orange
            isPrimaryButtonEnabled = false
        }
        return KYCInformationViewConfig(
            titleColor: titleColor,
            isPrimaryButtonEnabled: isPrimaryButtonEnabled
        )
    }
}
