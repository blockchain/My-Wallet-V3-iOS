//
//  KYCVerifyIdentityController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Onfido
import RxSwift
import UIKit

/// Account verification screen in KYC flow
final class KYCVerifyIdentityController: KYCBaseViewController {
    
    enum VerificationProviders {
        case onfido
    }

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCVerifyIdentityController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .verifyIdentity
        return controller
    }

    // MARK: - Properties

    private let onfidoService = OnfidoService()

    private let currentProvider = VerificationProviders.onfido

    fileprivate enum DocumentMap {
        case driversLicense, identityCard, passport, residencePermitCard
    }

    fileprivate var onfidoMap = [DocumentMap.driversLicense: DocumentType.drivingLicence,
                                 DocumentMap.identityCard: DocumentType.nationalIdentityCard,
                                 DocumentMap.passport: DocumentType.passport,
                                 DocumentMap.residencePermitCard: DocumentType.residencePermit]

    private var country: KYCCountry?

    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: - KYCCoordinatorDelegate

    override func apply(model: KYCPageModel) {
        guard case let .verifyIdentity(country) = model else { return }
        self.country = country
    }

    // MARK: - Private Methods

    private func setUpAndShowDocumentDialog() {
        let documentDialog = UIAlertController(title: LocalizationConstants.KYC.whichDocumentAreYouUsing, message: nil, preferredStyle: .actionSheet)
        let passportAction = UIAlertAction(title: LocalizationConstants.KYC.passport, style: .default, handler: { _ in
            self.didSelect(.passport)
        })
        let driversLicenseAction = UIAlertAction(title: LocalizationConstants.KYC.driversLicense, style: .default, handler: { _ in
            self.didSelect(.driversLicense)
        })
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        documentDialog.addAction(passportAction)
        documentDialog.addAction(driversLicenseAction)
        documentDialog.addAction(cancelAction)
        present(documentDialog, animated: true)
    }

    /// Sets up the Onfido config depending on user selection
    ///
    /// - Parameters:
    ///   - document: Onfido document type
    ///   - countryCode: Users locale
    /// - Returns: a configuration determining the onfido document verification
    private func onfidoConfigurator(
        _ document: DocumentType,
        _ onfidoUser: OnfidoUser,
        _ providerCredentials: OnfidoCredentials
    ) -> OnfidoConfig? {
        guard let country = country else {
            Logger.shared.warning("Cannot construct OnfidoConfig. Country is nil.")
            return nil
        }

        let config = try? OnfidoConfig.builder()
            .withToken(providerCredentials.key)
            .withApplicantId(onfidoUser.identifier)
            .withDocumentStep(ofType: document, andCountryCode: country.code)
            .withFaceStep(ofVariant: .video)
            .build()
        return config
    }

    /// Asks for credentials for a given identity verification provider and once obtained launch the Onfido flow
    ///
    /// - Parameters:
    ///   - provider: Object with a provider and API key
    func credentialsRequest(provider: VerificationProviders, documentType: DocumentType) {
        guard case .onfido = provider else {
            Logger.shared.warning("Only Onfido is the supported provider as of now.")
            return
        }

        disposable = BlockchainDataRepository.shared.fetchNabuUser().flatMap { [unowned self] user in
            return self.onfidoService.createUserAndCredentials(user: user)
        }.subscribeOn(MainScheduler.asyncInstance).observeOn(MainScheduler.instance).subscribe(onSuccess: { (onfidoUser, token) in
            self.launchOnfidoController(documentType, onfidoUser, token)
        }, onError: { error in
            Logger.shared.error("Failed to get onfido user and credentials. Error: \(error.localizedDescription)")
        })
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
            credentialsRequest(provider: provider, documentType: selectedOption)
        }
    }

    private func didSelect(_ document: DocumentMap) {
        startVerificationFlow(document, provider: currentProvider)
    }

    private func launchOnfidoController(_ document: DocumentType, _ user: OnfidoUser, _ credentials: OnfidoCredentials) {
        guard let currentConfig = self.onfidoConfigurator(document, user, credentials) else {
            Logger.shared.warning("Cannot launch OnfidoController.")
            return
        }
        let onfidoController = OnfidoController(config: currentConfig)
        onfidoController.user = user
        onfidoController.delegate = self
        onfidoController.modalPresentationStyle = .overCurrentContext
        self.present(onfidoController, animated: true)
    }

    // MARK: - Actions

    @IBAction private func primaryButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.setUpAndShowDocumentDialog()
        }
    }
}

extension KYCVerifyIdentityController: OnfidoControllerDelegate {
    func onOnfidoControllerCancelled(_ onfidoController: OnfidoController) {
        onfidoController.dismiss(animated: true)
    }

    func onOnfidoControllerErrored(_ onfidoController: OnfidoController, error: Error) {
        onfidoController.dismiss(animated: true) {
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.error)
        }
    }

    func onOnfidoControllerSuccess(_ onfidoController: OnfidoController) {
        onfidoController.dismiss(animated: true)
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.KYC.submittingInformation)
        _ = onfidoService.submitVerification(onfidoController.user)
            .subscribe(onCompleted: { [unowned self] in
                LoadingViewPresenter.shared.hideBusyView()
                self.coordinator.handle(event: .nextPageFromPageType(self.pageType, nil))
            }, onError: { error in
                LoadingViewPresenter.shared.hideBusyView()
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
                Logger.shared.error("Failed to submit verification \(error.localizedDescription)")
            })
    }
}
