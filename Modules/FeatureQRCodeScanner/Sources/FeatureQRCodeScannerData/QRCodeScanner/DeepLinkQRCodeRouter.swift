// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureQRCodeScannerDomain
import PlatformKit

public final class DeepLinkQRCodeRouter {

    // MARK: - Properties

    private let deepLinkHandler: DeepLinkHandling
    private let deepLinkRouter: DeepLinkRouting
    private let supportedRoutes: [DeepLinkRoute]

    // MARK: - Setup

    /// Initialised with supported routes as we don't want the client to act on any known route
    public init(
        supportedRoutes: [DeepLinkRoute],
        deepLinkHandler: DeepLinkHandling = resolve(),
        deepLinkRouter: DeepLinkRouting = resolve()
    ) {
        self.supportedRoutes = supportedRoutes
        self.deepLinkHandler = deepLinkHandler
        self.deepLinkRouter = deepLinkRouter
    }

    @discardableResult
    public func routeIfNeeded(using scanResult: Result<String, QRScannerError>) -> Bool {
        switch scanResult {
        case .success(let link): // Act immediately on the received link
            routeIfNeeded(using: link)
        case .failure:
            false
        }
    }

    /// Uses the given link for routing (if needed)
    public func routeIfNeeded(using link: String) -> Bool {
        guard let link = link.removingPercentEncoding else { return false }
        deepLinkHandler.handle(deepLink: link, supportedRoutes: supportedRoutes)
        return deepLinkRouter.routeIfNeeded()
    }
}
