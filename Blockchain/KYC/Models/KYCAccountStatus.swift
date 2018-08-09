//
//  KYCAccountStatus.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCAccountStatus: Int {
    case approved, failed, underReview, inProgress

    /// Graphic which visually represents the account status
    var image: UIImage? {
        switch self {
        case .approved: return UIImage(named: "AccountApproved")
        case .failed:   return UIImage(named: "AccountFailed")
        case .underReview: return UIImage(named: "AccountInReview")
        case .inProgress: return UIImage(named: "AccountInReview")
        }
    }

    /// Title which represents the account status
    var title: String {
        switch self {
        case .approved: return LocalizationConstants.KYC.accountApproved
        case .failed:   return LocalizationConstants.KYC.verificationFailed
        case .underReview: return LocalizationConstants.KYC.verificationUnderReview
        case .inProgress: return LocalizationConstants.KYC.verificationInProgress
        }
    }

    /// Subtitle for the account status
    var subtitle: String? {
        switch self {
        case .inProgress: return LocalizationConstants.KYC.whatHappensNext
        default: return nil
        }
    }

    /// Description of the account status
    var description: String {
        switch self {
        case .approved: return LocalizationConstants.KYC.accountApprovedDescription
        case .failed:   return LocalizationConstants.KYC.verificationFailedDescription
        case .underReview: return LocalizationConstants.KYC.verificationUnderReviewDescription
        case .inProgress: return LocalizationConstants.KYC.verificationInProgressDescription
        }
    }

    /// Title of the primary button.
    var primaryButtonTitle: String? {
        switch self {
        case .approved: return LocalizationConstants.KYC.getStarted
        case .failed:   return LocalizationConstants.KYC.contactSupport
        case .underReview: return nil
        case .inProgress: return LocalizationConstants.KYC.notifyMe
        }
    }
}
