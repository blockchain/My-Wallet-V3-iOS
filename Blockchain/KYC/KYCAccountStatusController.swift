//
//  KYCAccountStatusController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class KYCAccountStatusController: KYCOnboardingController {

    // MARK: - Properties

    enum AccountStatus {
        case approved, failed, inReview
        /// Graphic which visually represents the account status
        var image: UIImage {
            switch self {
            case .approved: return UIImage(named: "AccountApproved")!
            case .failed:   return UIImage(named: "AccountFailed")!
            case .inReview: return UIImage(named: "AccountInReview")!
            }
        }
        /// Title which represents the account status
        var title: String {
            switch self {
            case .approved: return "Account Approved!"
            case .failed:   return "Verification Failed"
            case .inReview: return "Account In Review"
            }
        }
        /// Description of the account status
        var description: String {
            switch self {
            case .approved: return "Congratulations! We verified your identity and you can now buy, sell, and exchange."
            case .failed:   return """
                We had some trouble verifying your account with the documents provided.
                Our support team will contact you shortly to help you with this issue.
                """
            case .inReview: return "Great job - you are now done. Your account should be approved in minutes."
            }
        }
        /// Title of the primary button
        var primaryButtonTitle: String? {
            switch self {
            case .approved: return "Get Started"
            case .failed:   return nil
            case .inReview: return "Notify Me"
            }
        }
    }

    /// Describes the status of the user's account
    var accountStatus: AccountStatus = .failed {
        didSet {
            setUpInterfaceFor(accountStatus)
        }
    }

    // MARK: - Private Methods

    private func setUpInterfaceFor(_ accountStatus: AccountStatus) {
        // This magic 🧙‍♂️✨ is required when using the UIStoryboard.instantiate extension
        guard self.view != nil else { return }
        titleLabel.text = accountStatus.title
        descriptionLabel.text = accountStatus.description
        imageView.image = accountStatus.image
        primaryButton.setTitle(accountStatus.primaryButtonTitle, for: .normal)
    }

    // MARK: - Actions

    override func primaryButtonTapped(_ sender: Any) {
        // TODO: implement primaryButtonTapped
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
