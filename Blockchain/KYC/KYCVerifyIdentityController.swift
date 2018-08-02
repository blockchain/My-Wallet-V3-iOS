//
//  KYCVerifyIdentityController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Account verification screen in KYC flow
final class KYCVerifyIdentityController: UIViewController {

    // MARK: - Properties

    fileprivate enum DocumentType {
        case driversLicense, identityCard, passport, residencePermitCard
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
        // TODO: Hook into Onfido SDK...
    }

    // MARK: - Actions

    @IBAction private func primaryButtonTapped(_ sender: Any) {
        setUpAndShowDocumentDialog()
    }
}
