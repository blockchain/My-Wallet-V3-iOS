//
//  KYCVerifyAccountController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Account verification screen in KYC flow
final class KYCVerifyAccountController: KYCOnboardingController {

    // MARK: - Properties

    fileprivate enum DocumentType {
        case driversLicense, identityCard, passport, residencePermitCard
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Verify your identity"
        // Depends on Onfido SDK integration...
        segueIdentifier = ""
        imageView.image = UIImage(named: "IdentityVerification")
        titleLabel.text = "Photo Verification Needed"
        descriptionLabel.text = "You're almost there! Just grab your government issued photo ID to complete your verification."
        primaryButton.setTitle("Continue", for: .normal)
    }

    private func setUpAndShowDocumentDialog() {
        let documentDialog = UIAlertController(title: "Which document are you using?", message: nil, preferredStyle: .actionSheet)
        let passportAction = UIAlertAction(title: "Passport", style: .default, handler: { _ in
            self.didSelect(.passport)
        })
        let driversLicenseAction = UIAlertAction(title: "Driver's License", style: .default, handler: { _ in
            self.didSelect(.driversLicense)
        })
        let identityCardAction = UIAlertAction(title: "Identity Card", style: .default, handler: { _ in
            self.didSelect(.identityCard)
        })
        let residencePermitCardAction = UIAlertAction(title: "Residence Permit Card", style: .default, handler: { _ in
            self.didSelect(.residencePermitCard)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        documentDialog.addAction(passportAction)
        documentDialog.addAction(driversLicenseAction)
        documentDialog.addAction(identityCardAction)
        documentDialog.addAction(residencePermitCardAction)
        documentDialog.addAction(cancelAction)

        present(documentDialog, animated: true)
    }

    // MARK: - Private Methods

    private func didSelect(_ document: DocumentType) {
        let accountStatusController = UIStoryboard.instantiate(
            child: KYCAccountStatusController.self,
            from: KYCOnboardingController.self,
            in: UIStoryboard(name: "KYCOnboardingScreen", bundle: nil),
            identifier: "OnboardingScreen"
        )
        accountStatusController.accountStatus = .inReview
        navigationController?.pushViewController(accountStatusController, animated: true)
    }

    // MARK: - Actions

    override func primaryButtonTapped(_ sender: Any) {
        setUpAndShowDocumentDialog()
    }
}
