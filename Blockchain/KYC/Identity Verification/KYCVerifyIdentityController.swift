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

    // MARK: - Views

    @IBOutlet private var nextButton: PrimaryButtonContainer!

    // MARK: - Properties

    private let onfidoService = OnfidoService()

    private let currentProvider = VerificationProviders.onfido

    private var countryCode: String?

    private var disposable: Disposable?

    private lazy var presenter: KYCVerifyIdentityPresenter = { [unowned self] in
        let interactor = KYCVerifyIdentityInteractor()
        return KYCVerifyIdentityPresenter(interactor: interactor, view: self)
    }()

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: - KYCCoordinatorDelegate

    override func apply(model: KYCPageModel) {
        guard case let .verifyIdentity(countryCode) = model else { return }
        self.countryCode = countryCode
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.actionBlock = { [unowned self] in
            guard let countryCode = self.countryCode else {
                return
            }
            self.presenter.presentDocumentTypeOptions(countryCode)
        }
    }

    // MARK: - Private Methods

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
        guard let countryCode = countryCode else {
            Logger.shared.warning("Cannot construct OnfidoConfig. Country code is nil.")
            return nil
        }

        let config = try? OnfidoConfig.builder()
            .withToken(providerCredentials.key)
            .withApplicantId(onfidoUser.identifier)
            .withDocumentStep(ofType: document, andCountryCode: countryCode)
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
        }.subscribeOn(MainScheduler.asyncInstance).observeOn(MainScheduler.instance).subscribe(onSuccess: { onfidoUser, token in
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
    fileprivate func startVerificationFlow(_ document: KYCDocumentType, provider: VerificationProviders) {
        switch provider {
        case .onfido:
            credentialsRequest(provider: provider, documentType: document.toOnfidoType())
        }
    }

    private func didSelect(_ document: KYCDocumentType) {
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
}

extension KYCVerifyIdentityController: KYCVerifyIdentityView {
    func showLoadingIndicator() {
        nextButton.isLoading = true
    }

    func hideLoadingIndicator() {
        nextButton.isLoading = false
    }

    func showDocumentTypesActionSheet(_ types: [KYCDocumentType]) {
        let documentDialog = UIAlertController(title: LocalizationConstants.KYC.whichDocumentAreYouUsing, message: nil, preferredStyle: .actionSheet)
        types.forEach { documentType  in
            let action = UIAlertAction(title: documentType.description, style: .default, handler: { [unowned self] _ in
                self.didSelect(documentType)
            })
            documentDialog.addAction(action)
        }
        documentDialog.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel))
        present(documentDialog, animated: true)
    }

    func showErrorMessage(_ message: String) {
        AlertViewPresenter.shared.standardError(message: message)
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
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.KYC.submittingInformation)
        _ = onfidoService.submitVerification(onfidoController.user)
            .subscribe(onCompleted: { [unowned self] in
                LoadingViewPresenter.shared.hideBusyView()
                self.dismiss(animated: true, completion: {
                    self.coordinator.handle(event: .nextPageFromPageType(self.pageType, nil))
                })
            }, onError: { error in
                LoadingViewPresenter.shared.hideBusyView()
                self.dismiss(animated: true, completion: {
                    AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
                })
                Logger.shared.error("Failed to submit verification \(error.localizedDescription)")
            })
    }
}

// MARK: KYCDocumentType

extension KYCDocumentType {
    func toOnfidoType() -> DocumentType {
        switch self {
        case .driversLicense:
            return DocumentType.drivingLicence
        case .passport:
            return DocumentType.passport
        case .nationalIdentityCard:
            return DocumentType.nationalIdentityCard
        }
    }
}
