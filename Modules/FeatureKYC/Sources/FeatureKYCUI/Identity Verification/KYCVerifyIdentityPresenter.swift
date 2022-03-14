// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

protocol KYCVerifyIdentityView: AnyObject {
    func showDocumentTypes(_ types: [KYCDocumentType])
}

protocol KYCVerifyIdentityDelegate: AnyObject {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func createCredentials(
        onSuccess: @escaping ((VeriffCredentials) -> Void),
        onError: @escaping ((Error) -> Void)
    )
}

class KYCVerifyIdentityPresenter {
    private let interactor: KYCVerifyIdentityInteractor
    private weak var loadingView: LoadingView?

    // TODO: Separate and use in a different presenter specifically made
    // for the KYCVerifyIdentityViewController.
    weak var identityView: KYCVerifyIdentityView?

    init(
        interactor: KYCVerifyIdentityInteractor,
        loadingView: LoadingView
    ) {
        self.interactor = interactor
        self.loadingView = loadingView
    }

    func presentDocumentTypeOptions(_ countryCode: String) {
        loadingView?.showLoadingIndicator()
        interactor.supportedDocumentTypes(
            countryCode: countryCode,
            onSuccess: { [weak self] documentTypes in
                self?.loadingView?.hideLoadingIndicator()
                self?.identityView?.showDocumentTypes(documentTypes)
            },
            onError: { [weak self] error in
                Logger.shared.error("Error: \(String(describing: error))")
                self?.loadingView?.hideLoadingIndicator()
                self?.loadingView?.showErrorMessage(LocalizationConstants.Errors.genericError)
            }
        )
    }

    // MARK: - CameraPrompting & MicrophonePrompting

    weak var cameraPromptingDelegate: CameraPromptingDelegate?
    weak var microphonePromptingDelegate: MicrophonePromptingDelegate?

    internal lazy var permissionsRequestor: PermissionsRequestor = PermissionsRequestor()
}

extension KYCVerifyIdentityPresenter: MicrophonePrompting {}

extension KYCVerifyIdentityPresenter: CameraPrompting {}

extension KYCVerifyIdentityPresenter: KYCVerifyIdentityDelegate {
    func submitVerification(onCompleted: @escaping (() -> Void), onError: @escaping ((Error) -> Void)) {
        interactor.submitVerification(onCompleted: onCompleted, onError: onError)
    }

    func createCredentials(onSuccess: @escaping ((VeriffCredentials) -> Void), onError: @escaping ((Error) -> Void)) {
        interactor.createCredentials(onSuccess: onSuccess, onError: onError)
    }

    func didTapNext() {
        willUseCamera()
    }
}
