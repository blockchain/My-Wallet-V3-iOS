//
//  KYCAccountStatus.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCAccountStatus: String {
    case none = "NONE"
    case expired = "EXPIRED"
    case approved = "VERIFIED"
    case failed = "REJECTED"
    case pending = "PENDING"

    /// Graphic which visually represents the account status
    var image: UIImage {
        switch self {
        case .approved: return #imageLiteral(resourceName: "AccountApproved")
        case .failed, .none, .expired:   return #imageLiteral(resourceName: "AccountFailed")
        case .pending: return #imageLiteral(resourceName: "AccountInReview")
        }
    }

    /// Title which represents the account status
    var title: String {
        switch self {
        case .approved: return LocalizationConstants.KYC.accountApproved
        case .pending: return LocalizationConstants.KYC.verificationUnderReview
        case .failed,
             .expired,
             .none:
            return LocalizationConstants.KYC.verificationFailed
        }
    }

    /// Subtitle for the account status
    var subtitle: String? {
        switch self {
        case .pending: return LocalizationConstants.KYC.whatHappensNext
        default: return nil
        }
    }

    /// Description of the account status
    var description: String {
        switch self {
        case .approved: return LocalizationConstants.KYC.accountApprovedDescription
        case .pending: return LocalizationConstants.KYC.verificationInProgressDescription
        case .expired,
             .none,
             .failed:
            return LocalizationConstants.KYC.verificationFailedDescription
        }
    }

    /// Title of the primary button.
    var primaryButtonTitle: String? {
        switch self {
        case .approved: return LocalizationConstants.KYC.getStarted
        case .failed:   return LocalizationConstants.KYC.contactSupport
        case .pending: return LocalizationConstants.KYC.notifyMe
        case .none, .expired: return nil
        }
    }

 var badge: String {
        switch self {
        case .approved: return LocalizationConstants.KYC.accounVerifiedBadge
        case .failed:   return LocalizationConstants.KYC.verificationFailedBadge
        case .pending: return LocalizationConstants.KYC.accountUnderReviewBadge
        default: return LocalizationConstants.KYC.accountPendingBadge
        }
    }
}


