// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol LinkBankFailureScreenBuildable {
    func build(withListener listener: LinkBankFailureScreenListener) -> LinkBankFailureScreenRouting
}

final class LinkBankFailureScreenBuilder: LinkBankFailureScreenBuildable {

    func build(withListener listener: LinkBankFailureScreenListener) -> LinkBankFailureScreenRouting {
        let interactor = LinkBankFailureScreenInteractor()
        let presenter = LinkBankFailureScreenPresenter(interactor: interactor)
        let viewController = PendingStateViewController(presenter: presenter)
        viewController.isModalInPresentation = true
        interactor.listener = listener
        return LinkBankFailureScreenRouter(interactor: interactor, viewController: viewController)
    }
}

extension PendingStateViewController: LinkBankFailureScreenViewControllable {}
