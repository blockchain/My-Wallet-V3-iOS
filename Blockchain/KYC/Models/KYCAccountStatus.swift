//
//  KYCAccountStatus.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCUserAddress: Codable {
    let city: String?
    let line1: String?
    let line2: String?
    let state: String?
    let country: String?
    let postCode: String?
}

struct KYCUserResponse: Codable {
    let firstName: String?
    let lastName: String?
    let email: String?
    let mobile: String?
    let mobileVerified: Bool
    let address: KYCUserAddress?
    let kycState: String
}

enum KYCAccountStatus: Int {
    case approved, failed, underReview, inProgress

    /// Graphic which visually represents the account status
    var image: UIImage {
        switch self {
        case .approved: return #imageLiteral(resourceName: "AccountApproved")
        case .failed:   return #imageLiteral(resourceName: "AccountFailed")
        case .underReview: return #imageLiteral(resourceName: "AccountInReview")
        case .inProgress: return #imageLiteral(resourceName: "AccountInReview")
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
    
    /// A badged display item of the account status
    var badge: String {
        switch self {
        case .approved: return LocalizationConstants.KYC.accounVerifiedBadge
        case .failed:   return LocalizationConstants.KYC.verificationFailedBadge
        case .underReview: return LocalizationConstants.KYC.accountUnderReviewBadge
        case .inProgress: return LocalizationConstants.KYC.accountPendingBadge
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
