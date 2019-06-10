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
}

struct KYCInformationViewConfig {
    let titleColor: UIColor
    let isPrimaryButtonEnabled: Bool
    let imageTintColor: UIColor?
}

extension KYCInformationViewModel {
    static func createForUnsupportedCountry(_ country: KYCCountry) -> KYCInformationViewModel {
        return KYCInformationViewModel(
            image: #imageLiteral(resourceName: "Welcome"),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, country.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedCountryDescription, country.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable
        )
    }

    static func createForUnsupportedState(_ state: KYCState) -> KYCInformationViewModel {
        return KYCInformationViewModel(
            image: #imageLiteral(resourceName: "Welcome"),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, state.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedStateDescription, state.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable
        )
    }

    static func create(
        for accountStatus: KYCAccountStatus,
        isReceivingAirdrop: Bool = false
    ) -> KYCInformationViewModel {
        switch accountStatus {
        case .approved:
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountApproved"),
                title: LocalizationConstants.KYC.accountApproved,
                subtitle: nil,
                description: LocalizationConstants.KYC.accountApprovedDescription,
                buttonTitle: LocalizationConstants.KYC.getStarted
            )
        case .expired, .failed:
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountFailed"),
                title: LocalizationConstants.KYC.verificationFailed,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationFailedDescription,
                buttonTitle: nil
            )
        case .pending:
            return createViewModelForPendingStatus(isReceivingAirdrop: isReceivingAirdrop)
        case .underReview:
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountInReview"),
                title: LocalizationConstants.KYC.verificationUnderReview,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationUnderReviewDescription,
                buttonTitle: nil
            )
        case .none:
            return KYCInformationViewModel(
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
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "Icon-Verified-Large"),
                title: LocalizationConstants.KYC.verificationInProgress,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationInProgressDescriptionAirdrop,
                buttonTitle: LocalizationConstants.KYC.notifyMe
            )
        } else {
            return KYCInformationViewModel(
                image: #imageLiteral(resourceName: "AccountInReview"),
                title: LocalizationConstants.KYC.verificationInProgress,
                subtitle: LocalizationConstants.KYC.whatHappensNext,
                description: LocalizationConstants.KYC.verificationInProgressDescription,
                buttonTitle: LocalizationConstants.KYC.notifyMe
            )
        }
    }
}

extension KYCInformationViewConfig {
    static let defaultConfig: KYCInformationViewConfig = KYCInformationViewConfig(
        titleColor: UIColor.gray5,
        isPrimaryButtonEnabled: false,
        imageTintColor: nil
    )

    static func create(for accountStatus: KYCAccountStatus, isReceivingAirdrop: Bool = false) -> KYCInformationViewConfig {
        let titleColor: UIColor
        let isPrimaryButtonEnabled: Bool
        var tintColor: UIColor?

        switch accountStatus {
        case .approved:
            titleColor = UIColor.green
            isPrimaryButtonEnabled = true
        case .failed, .expired, .none:
            titleColor = UIColor.error
            isPrimaryButtonEnabled = false
        case .pending:
            titleColor = isReceivingAirdrop ? UIColor.green : UIColor.pending
            isPrimaryButtonEnabled = !UIApplication.shared.isRegisteredForRemoteNotifications
            tintColor = isReceivingAirdrop ? UIColor.brandSecondary : nil
        case .underReview:
            titleColor = .orange
            isPrimaryButtonEnabled = false
        }
        return KYCInformationViewConfig(
            titleColor: titleColor,
            isPrimaryButtonEnabled: isPrimaryButtonEnabled,
            imageTintColor: tintColor
        )
    }
}
