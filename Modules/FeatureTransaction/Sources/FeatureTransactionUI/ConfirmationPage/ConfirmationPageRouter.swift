// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import UIComponentsKit

protocol ConfirmationPageRouting: AnyObject {
    func showWebViewWithTitledLink(_ titledLink: TitledLink)
    func showACHDepositTerms(termsDescription: String)
    func showAvailableToWithdrawDateInfo()
}

final class ConfirmationPageRouter: ViewableRouter<Interactable, ViewControllable>, ConfirmationPageRouting {

    private let app: AppProtocol
    private let webViewRouter: WebViewRouterAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding

    init(
        app: AppProtocol = DIKit.resolve(),
        interactor: ConfirmationPageInteractable,
        viewController: ViewControllable,
        webViewRouter: WebViewRouterAPI = resolve(),
        topMostViewControllerProvider: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.webViewRouter = webViewRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func showWebViewWithTitledLink(_ titledLink: TitledLink) {
        webViewRouter.launchRelay.accept(titledLink)
    }

    func showACHDepositTerms(termsDescription: String) {
        guard let topVC = topMostViewControllerProvider.topMostViewController else {
            return
        }
        let loc = LocalizationConstants.Transaction.Deposit.Confirmation.DepositACHTermsDetails.self
        let view = ConfirmationPageDetailsTermsView(
            title: loc.title,
            description: termsDescription,
            doneButtonTitle: loc.doneButton
        ) { [weak topVC] in
            topVC?.dismiss(animated: true)
        }
        let controller = UIHostingController(rootView: view)
        topVC.present(controller, animated: true)
    }

    func showAvailableToWithdrawDateInfo() {
        guard let topVC = topMostViewControllerProvider.topMostViewController else {
            return
        }

        guard let readMoreUrl = try? app.remoteConfiguration.get(
            blockchain.ux.transaction["buy"].checkout.terms.of.withdraw,
            as: URL.self
        ) else { return }

        let loc = LocalizationConstants.Transaction.Deposit.Confirmation.AvailableWithdrawalDatesInfo.self
        let view = ConfirmationPageAvaiableWithdrawalInfoView(
            title: loc.title,
            description: loc.description,
            readMoreButtonTitle: loc.readMoreButton,
            readMoreUrl: readMoreUrl
        ) { [weak topVC] in
            topVC?.dismiss(animated: true)
        }
        let controller = UIHostingController(rootView: view)

        controller.modalPresentationStyle = .pageSheet

        if let sheet = controller.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { _ in 250 },
                    .medium()
                ]
            } else {
                sheet.detents = [
                    .medium()
                ]
            }
            sheet.prefersGrabberVisible = true
        }
        topVC.present(controller, animated: true, completion: nil)
    }
}
