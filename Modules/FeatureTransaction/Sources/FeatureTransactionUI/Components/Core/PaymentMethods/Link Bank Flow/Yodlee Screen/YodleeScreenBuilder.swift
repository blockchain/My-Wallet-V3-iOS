// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs
import WebKit

// MARK: - Builder

protocol YodleeScreenBuildable {
    func build(withListener listener: LinkBankListener, data: BankLinkageData) -> YodleeScreenRouting
}

final class YodleeScreenBuilder: YodleeScreenBuildable {

    func build(withListener listener: LinkBankListener, data: BankLinkageData) -> YodleeScreenRouting {
        let webConfiguration = provideYodleeConfiguration()
        let messageHandler = YodleeMessageHandler(webViewConfiguration: webConfiguration)
        let messageService = YodleeMessageService(messageHandler: messageHandler, parser: yodleeMessageParser)
        let activationService = YodleeActivateService()
        let contentReducer = YodleeScreenContentReducer()
        let yodleeRequestProvider = YodleeRequestProvider()
        let viewController = YodleeScreenViewController(webConfiguration: webConfiguration)
        let interactor = YodleeScreenInteractor(
            presenter: viewController,
            bankLinkageData: data,
            yodleeRequestProvider: yodleeRequestProvider,
            yodleeMessageService: messageService,
            yodleeActivationService: activationService,
            contentReducer: contentReducer
        )
        interactor.listener = listener
        return YodleeScreenRouter(interactor: interactor, viewController: viewController)
    }

    private func provideYodleeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsAirPlayForMediaPlayback = false
        configuration.allowsInlineMediaPlayback = false
        configuration.allowsPictureInPictureMediaPlayback = false
        return configuration
    }
}
