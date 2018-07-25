//
//  AccountStatusController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public class AccountStatusController: OnboardingController {

    // MARK: - Properties

    enum AccountStatus {
        case inReview, approved, failed
    }

    var accountStatus: AccountStatus = .inReview

    // MARK: - View Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpInterfaceFor(accountStatus)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setUpInterfaceFor(_ accountStatus: AccountStatus) {
        switch accountStatus {
        case .inReview:
            titleLabel.text = "Account In Review"
            imageView.image = UIImage(named: "AccountInReview")
            descriptionLabel.text = "Great job - you are now done. Your account should be approved in minutes."
            primaryButton.setTitle("Notify Me", for: .normal)
        case .approved:
            titleLabel.text = "Account Approved!"
            imageView.image = UIImage(named: "AccountApproved")
            descriptionLabel.text = "Congratulations! We verified your identity and you can now buy, sell, and exchange."
            primaryButton.setTitle("Get Started", for: .normal)
        case .failed:
            titleLabel.text = "Verification Failed"
            imageView.image = UIImage(named: "AccountFailed")
            descriptionLabel.text = """
            We had some trouble verifying your account with the documents provided.
            Our support team will contact you shortly to help you with this issue.
            """
        }
    }

    // MARK: - Actions

    override public func primaryButtonTapped(_ sender: Any) {
    
    }

    // MARK: - Navigation

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
