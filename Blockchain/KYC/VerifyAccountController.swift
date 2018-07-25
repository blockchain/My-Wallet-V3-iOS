//
//  VerifyAccountController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Account verification screen in KYC flow
open class VerifyAccountController: OnboardingController {

    // MARK: - Properties

    fileprivate enum DocumentType {
        case passport, driversLicense, identityCard, residencePermitCard
    }

    private var documentDialog: UIAlertController!

    // MARK: - View Lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Verify your identity"
        // Depends on Onfido SDK integration...
        segueIdentifier = ""
        imageView.image = UIImage(named: "IdentityVerification")
        titleLabel.text = "Photo Verification Needed"
        descriptionLabel.text = "You're almost there! Just grab your government issued photo ID to complete your verification."
        primaryButton.setTitle("Continue", for: .normal)
        setUpDocumentDialog()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setUpDocumentDialog() {
        documentDialog = UIAlertController(title: "Which document are you using?", message: nil, preferredStyle: .actionSheet)
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
    }

    private func didSelect(_ document: DocumentType) {
        let verifyAccountController = UIStoryboard.instantiate(
            child: AccountStatusController.self,
            from: OnboardingController.self,
            in: UIStoryboard(name: "OnboardingScreen", bundle: Bundle(identifier: "com.rainydayapps.BlockchainKYC")),
            identifier: "OnboardingScreen"
        )
        self.navigationController?.pushViewController(verifyAccountController, animated: true)
    }

    // MARK: - Actions

    override open func primaryButtonTapped(_ sender: Any) {
        self.present(documentDialog, animated: true)
    }

    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let accountVerificationController = segue.destination as? AccountStatusController else {
            fatalError()
        }
        // accountVerificationController.
    }
}
