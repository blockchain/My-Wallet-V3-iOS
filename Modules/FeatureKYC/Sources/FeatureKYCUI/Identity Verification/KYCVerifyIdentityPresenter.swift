// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PermissionsKit
import PlatformKit
import PlatformUIKit
import ToolKit

protocol KYCVerifyIdentityView: AnyObject {}

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
    weak var identityView: KYCVerifyIdentityView?

    init(
        interactor: KYCVerifyIdentityInteractor
    ) {
        self.interactor = interactor
    }

    // MARK: - CameraPrompting & MicrophonePrompting

    weak var cameraPromptingDelegate: CameraPromptingDelegate?
    weak var microphonePromptingDelegate: MicrophonePromptingDelegate?

    lazy var permissionsRequestor: PermissionsRequestor = PermissionsRequestor()
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
