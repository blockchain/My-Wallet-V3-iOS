// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RIBs

struct LinkBankSplashScreen {
    enum Path {
        case link(url: URL)
    }
}

protocol LinkBankSplashScreenInteractable: Interactable {
    var router: LinkBankSplashScreenRouting? { get set }
    var listener: LinkBankSplashScreenListener? { get set }
}

protocol LinkBankSplashScreenViewControllable: ViewControllable {}

final class LinkBankSplashScreenRouter: ViewableRouter<LinkBankSplashScreenInteractable, LinkBankSplashScreenViewControllable>,
    LinkBankSplashScreenRouting
{

    private let webViewService: WebViewServiceAPI

    init(
        interactor: LinkBankSplashScreenInteractable,
        viewController: LinkBankSplashScreenViewControllable,
        webViewServiceAPI: WebViewServiceAPI = resolve()
    ) {
        self.webViewService = webViewServiceAPI
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func route(to path: LinkBankSplashScreen.Path) {
        switch path {
        case .link(let url):
            webViewService.openSafari(url: url, from: viewController.uiviewController)
        }
    }
}
