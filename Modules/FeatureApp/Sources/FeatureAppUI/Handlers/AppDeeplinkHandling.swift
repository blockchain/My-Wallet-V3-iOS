// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import FeatureSettingsDomain
import Foundation
import Localization
import PlatformKit
import ToolKit

// MARK: - Protocols

/// Types adopting `AppDeeplinkHandlerAPI` can handle incoming `DeeplinkContext`
public protocol AppDeeplinkHandlerAPI {
    /// Determines if the url can be handled or not
    /// - Parameter deeplink: A `DeeplinkContext` to be handled
    func canHandle(deeplink: DeeplinkContext) -> Bool

    /// Handles the given deeplink context
    /// - Parameter deeplink: A `DeeplinkContext` to be handled
    /// - Returns: A stream of `AnyPublisher<DeeplinkOutcome, AppDeeplinkError>`.
    func handle(deeplink: DeeplinkContext) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError>
}

/// Types adopting `AppDeeplinkHandling` can handle incoming URLs
public protocol URIHandlingAPI {
    /// Determines if the url can be handled or not
    /// - Parameter url: A `URL` representing the scheme and path
    func canHandle(url: URL) -> Bool
    /// Handles the given url
    /// - Parameter url: A `URL` to be handled
    /// - Returns: A stream of `AnyPublisher<DeeplinkOutcome, AppDeeplinkError>`.
    func handle(url: URL) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError>
}

// MARK: - Models/Context

/// The context of a deeplink
public enum DeeplinkContext {
    case url(URL)
    case userActivity(NSUserActivity)

    var url: URL? {
        switch self {
        case .url(let url):
            return url
        case .userActivity(let activity):
            return activity.appOpenableUrl
        }
    }
}

/// The outcome after a deeplink is handled
public enum DeeplinkOutcome: Equatable {
    case informAppNeedsUpdate
    case handleLink(URIContent)
    case ignore
}

/// A struct that contains information of a deeplink
public struct URIContent: Equatable {
    public enum Context: Equatable {
        /// Firebase related handling
        case dynamicLinks
        /// Verify device handling - during login
        case blockchainLinks(BlockchainLinks.Route)
        /// Handles legacy routing
        case executeDeeplinkRouting
        /// Routes to send crypto screen
        case sendCrypto

        /// `true` if the context should only be taken into account while we're authentication (welcome screen), otherwise `false`
        var usableOnlyDuringAuthentication: Bool {
            switch self {
            case .blockchainLinks(let route):
                return route.usableOnlyDuringAuthentication
            case .dynamicLinks,
                 .executeDeeplinkRouting,
                 .sendCrypto:
                return false
            }
        }
    }

    /// The `URL` content of a deeplink
    public let url: URL
    /// The context of a deeplink
    public let context: Context

    /// `true` if that the deeplink should be deferred after authentication, otherwise `false`
    var deferUntilAuthenticated: Bool {
        switch context {
        case .executeDeeplinkRouting,
             .sendCrypto:
            return true
        case .blockchainLinks,
             .dynamicLinks:
            return false
        }
    }

    public init(url: URL, context: URIContent.Context) {
        self.url = url
        self.context = context
    }
}

/// A enum defining error that can occur while handling a deeplink
public enum AppDeeplinkError: LocalizedError {
    case dynamicLink(Error)
    case urlMissing
    case unknown

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return LocalizationConstants.Errors.genericError
        case .urlMissing:
            // TODO: Add correct error message
            return LocalizationConstants.Errors.genericError
        case .dynamicLink(let error):
            return error.localizedDescription
        }
    }
}

public enum BlockchainLinks: Equatable {
    public enum Route: String, CaseIterable {
        case login

        /// `true` if the context should only be taken into account while we're authentication (welcome screen), otherwise `false`
        var usableOnlyDuringAuthentication: Bool {
            switch self {
            case .login:
                return true
            }
        }
    }

    /// Defines routes that can be handled as part of a universal-link
    /// - NOTE: Currently only login route is supported
    /// we should provide a better registry for possible routes
    public static let validRoutes: Set<String> = Set(BlockchainLinks.Route.allCases.map(\.rawValue))

    // TODO: These should not be hard-coded here, define them in environment variables?
    /// Defines url links that can be handled as part of a universal-link
    public static let validLinks: Set<String> = [
        "login.blockchain.com",
        "login-staging.blockchain.com",
        "login-dev.blockchain.com"
    ]
}

// MARK: - AppDeeplinkHandler

/// A top-level concrete handler for deeplinks
public final class AppDeeplinkHandler: AppDeeplinkHandlerAPI {

    private let coreDeeplinkHandler: URIHandlingAPI
    private let blockchainHandler: URIHandlingAPI
    private let firebaseHandler: URIHandlingAPI

    public init(
        deeplinkHandler: URIHandlingAPI,
        blockchainHandler: URIHandlingAPI,
        firebaseHandler: URIHandlingAPI
    ) {
        self.coreDeeplinkHandler = deeplinkHandler
        self.blockchainHandler = blockchainHandler
        self.firebaseHandler = firebaseHandler
    }

    public func handle(deeplink: DeeplinkContext) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError> {
        guard canHandle(deeplink: deeplink) else {
            return .just(.ignore)
        }
        switch deeplink {
        case .url(let url):
            return coreDeeplinkHandler.handle(url: url)
        case .userActivity(let activity):
            guard let url = activity.appOpenableUrl else {
                return Fail(error: .urlMissing)
                    .eraseToAnyPublisher()
            }
            // check if the given url can be handled by the blockchainHandler
            guard blockchainHandler.canHandle(url: url) else {
                return firebaseHandler.handle(url: url)
            }
            return blockchainHandler.handle(url: url)
        }
    }

    public func canHandle(deeplink: DeeplinkContext) -> Bool {
        guard let url = deeplink.url else {
            return false
        }
        return firebaseHandler.canHandle(url: url)
            || coreDeeplinkHandler.canHandle(url: url)
            || blockchainHandler.canHandle(url: url)
    }
}

// MARK: CoreDeeplinkHandler

/// Concrete implementation of URL based deep linking
/// This is intentional marked as public, as it needs access to some services that are still on the main target.
///
/// - Note:
///  - When `AssetConstants.URLSchemes.blockchainWallet` -> ignores
///  - When `AssetConstants.URLSchemes.blockchain` -> ignores
///  - When `BitPayLinkRouter.isBitPayURL(url)` -> .handleLink / executeDeeplinkRouting
///  - When `BitcoinURLPayload(url: url)` -> .handleLink / .sendCrypto
public final class CoreDeeplinkHandler: URIHandlingAPI {

    private let isPinSet: () -> Bool

    private let markBitpayUrl: (URL) -> Void
    private let isBitPayURL: (URL) -> Bool

    public init(
        markBitpayUrl: @escaping (URL) -> Void,
        isBitPayURL: @escaping (URL) -> Bool,
        isPinSet: @escaping () -> Bool
    ) {
        self.markBitpayUrl = markBitpayUrl
        self.isBitPayURL = isBitPayURL
        self.isPinSet = isPinSet
    }

    public func handle(url: URL) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError> {
        // we want to ignore early if there's no pin set
        guard isPinSet() else {
            return .just(.ignore)
        }
        guard let scheme = url.scheme else {
            return .just(.ignore)
        }

        if scheme == AssetConstants.URLSchemes.blockchainWallet {
            return .just(.ignore)
        }
        if scheme == AssetConstants.URLSchemes.blockchain {
            return .just(.ignore)
        }

        if isBitPayURL(url) {
            markBitpayUrl(url)
            let content = URIContent(url: url, context: .executeDeeplinkRouting)
            return .just(.handleLink(content))
        }

        if BIP21URI<BitcoinToken>(url: url) != nil {
            let content = URIContent(url: url, context: .sendCrypto)
            return .just(.handleLink(content))
        }

        return .just(.ignore)
    }

    public func canHandle(url: URL) -> Bool {
        isPinSet()
    }
}

// MARK: BlockchainLinksHandler

public final class BlockchainLinksHandler: URIHandlingAPI {

    private let validHosts: Set<String>
    private let validRoutes: Set<String>

    /// Initializes the blockchain universal links handler
    /// - Parameter validHosts: A `Set<String>` that contains valid url hosts to be taken into account
    /// - Parameter validRoutes: A `Set<String>` that contains valid path prefix, eg /login/
    public init(validHosts: Set<String>, validRoutes: Set<String>) {
        self.validHosts = validHosts
        self.validRoutes = validRoutes
    }

    public func handle(url: URL) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError> {
        // this is naive, we should have a proper 1:1 mapping of possible routes
        // Please note that the URL might contain a `/#/` which is consider
        // a fragment a part of the RFC 1808 standard, so we need to check both.
        let pathOrFragment = url.fragment ?? url.path
        let route = pathOrFragment.split(separator: "/").first
        guard let route,
              validRoutes.contains(String(route))
        else {
            Logger.shared.warning("unhandled route for url: \(url)")
            return .just(.ignore)
        }
        guard let usableRoute = BlockchainLinks.Route(rawValue: String(route)) else {
            Logger.shared.warning("unknown route for url: \(url)")
            return .just(.ignore)
        }
        let content = URIContent(url: url, context: .blockchainLinks(usableRoute))
        return .just(.handleLink(content))
    }

    public func canHandle(url: URL) -> Bool {
        guard let host = url.host else {
            return false
        }
        return validHosts.contains(host)
    }
}

// MARK: FirebaseDeeplinkHandler

public protocol DynamicLinkAPI {
    var minimumAppVersion: String? { get }
    var url: URL? { get }
}

public protocol DynamicLinksAPI: AnyObject {

    @discardableResult
    func handleUniversalLink(url: URL, _ completion: @escaping (DynamicLinkAPI?, Error?) -> Void) -> Bool

    func canHandle(url: URL) -> Bool
}

public final class FirebaseDeeplinkHandler: URIHandlingAPI {
    private let dynamicLinks: DynamicLinksAPI

    public init(dynamicLinks: DynamicLinksAPI) {
        self.dynamicLinks = dynamicLinks
    }

    public func handle(url: URL) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError> {
        Deferred { [dynamicLinks] in
            Future<DeeplinkOutcome, AppDeeplinkError> { promise in
                dynamicLinks.handleUniversalLink(url: url) { dynamicLink, error in
                    // Check that the version of the link (if provided) is supported, if not, prompt the user to update
                    if let minimumAppVersion = dynamicLink?.minimumAppVersion.flatMap(AppVersion.init(string:)),
                       let appVersion = Bundle.applicationVersion.flatMap(AppVersion.init(string:)),
                       appVersion < minimumAppVersion
                    {
                        return promise(.success(.informAppNeedsUpdate))
                    }

                    do {
                        if let error { throw error }

                        var dynamicURL = try (dynamicLink?.url)
                            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
                            .or(throw: AppDeeplinkError.urlMissing)

                        let base = try URLComponents(url: url, resolvingAgainstBaseURL: false)
                            .or(throw: AppDeeplinkError.urlMissing)

                        dynamicURL.queryItems = dynamicURL.queryItems.or(default: [])
                            + base.queryItems.or(default: [])

                        let url = try dynamicURL.url
                            .or(throw: AppDeeplinkError.urlMissing)

                        let content = URIContent(url: url, context: .dynamicLinks)
                        promise(.success(.handleLink(content)))
                    } catch let error as AppDeeplinkError {
                        promise(.failure(error))
                    } catch {
                        promise(.failure(.dynamicLink(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func canHandle(url: URL) -> Bool {
        dynamicLinks.canHandle(url: url)
    }
}

// MARK: - Private

extension NSUserActivity {
    fileprivate var appOpenableUrl: URL? {
        guard activityType == NSUserActivityTypeBrowsingWeb, let url = webpageURL else {
            return nil
        }
        return url
    }
}
