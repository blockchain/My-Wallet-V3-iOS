//
//  KYCVerifyIdentityController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import Onfido

struct VerificationPayload: Codable {
    var provider: String
    var key: String
}

/// Account verification screen in KYC flow
final class KYCVerifyIdentityController: UIViewController {
    
    enum VerificationProviders {
        case onfido
    }

    
    // MARK: - Properties
    
    var currentProvider = VerificationProviders.onfido
    
    fileprivate enum DocumentMap {
        case driversLicense, identityCard, passport, residencePermitCard
    }

    fileprivate var onfidoMap = [DocumentMap.driversLicense: DocumentType.drivingLicence,
                                 DocumentMap.identityCard: DocumentType.nationalIdentityCard,
                                 DocumentMap.passport: DocumentType.passport,
                                 DocumentMap.residencePermitCard: DocumentType.residencePermit]
    
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
    
    /// Sets up the Onfido config depending on user selection
    ///
    /// - Parameters:
    ///   - document: Onfido document type
    ///   - countryCode: Users locale
    /// - Returns: a configuration determining the onfido document verification
    private func onfidoConfigurator(_ document: DocumentType, countryCode: String, _ providerCredentials: VerificationPayload) -> OnfidoConfig {
        //swiftlint:disable next force_try
        let config = try! OnfidoConfig.builder()
            .withToken(providerCredentials.key)
            .withApplicantId("applicant")
            .withDocumentStep(ofType: document, andCountryCode: countryCode)
            .withFaceStep(ofVariant: .photo) // specify the face capture variant here
            .build()
        return config
    }

    /// Asks for credentials for a given identity verification provider
    ///
    /// - Parameters:
    ///   - provider: Object with a provider and API key
    ///   - completion: @param VerificationPayload
    func cedentialsRequest(provider: VerificationProviders, completion: @escaping (VerificationPayload) -> Void) {
        switch provider {
        case .onfido:
            KYCNetworkRequest(get: .credentials, taskSuccess: { responseData in
                do {
                    let decoder = JSONDecoder()
                    let verificationVendors = try decoder.decode([VerificationPayload].self, from: responseData)
                    guard let firstProvider = verificationVendors.first else {
                        return
                    }
                    completion(firstProvider)
                } catch {
                    Logger.shared.error("Decoding Failed")
                }
            }, taskFailure: { error in
                // TODO: handle error
                Logger.shared.error(error.debugDescription)
            })
        }
    }
    /// Begins identity verification and presents the view
    ///
    /// - Parameters:
    ///   - document: enum of identity types mapped to an identity provider
    ///   - provider: the current provider of verification services
    fileprivate func startVerificationFlow(_ document: DocumentMap, provider: VerificationProviders) {
        switch provider {
        case .onfido:
            guard let selectedOption = onfidoMap[document] else {
                return
            }
            cedentialsRequest(provider: provider) { credentials in
                let currentConfig = self.onfidoConfigurator(selectedOption, countryCode: "USD", credentials)
                let onfidoController = OnfidoController(config: currentConfig)
                onfidoController.modalPresentationStyle = .overCurrentContext
                self.present(onfidoController, animated: true)
            }
        }
    }
    
    private func didSelect(_ document: DocumentMap) {
        startVerificationFlow(document, provider: currentProvider)
    }
    
    // MARK: - Actions
    
    @IBAction private func primaryButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.setUpAndShowDocumentDialog()
        }
    }
}
