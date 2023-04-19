// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import ToolKit

public typealias APICode = String

public enum Network {

    public struct Config {

        let apiScheme: String?
        let apiHost: String
        let apiCode: String
        let pathComponents: [String]

        static let defaultConfig = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.apiHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: []
        )

        static let retailConfig = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.apiHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: ["nabu-gateway"]
        )

        static let explorerConfig = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.explorerHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: []
        )

        static let walletConfig = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.walletHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: []
        )

        static let everypayConfig = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.everyPayHost,
            apiCode: "",
            pathComponents: []
        )

        public static let websocketConfig = Config(
            apiScheme: "wss",
            apiHost: InfoDictionaryHelper.value(for: .websocketURL),
            apiCode: "",
            pathComponents: []
        )

        public static let iterableConfig = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.PartnerHosts.iterable.rawValue,
            apiCode: "",
            pathComponents: ["api"]
        )
    }
}

extension Network.Config {

    public init(
        scheme: String? = nil,
        host: String,
        code: String = BlockchainAPI.Parameters.apiCode,
        components: [String] = []
    ) {
        self.init(apiScheme: scheme, apiHost: host, apiCode: code, pathComponents: components)
    }
}

public class UserAgentProvider {

    private var deviceInfo: DeviceInfo

    public init(deviceInfo: DeviceInfo = resolve()) {
        self.deviceInfo = deviceInfo
    }

    public var userAgent: String? {
        guard
            let version = Bundle.applicationVersion,
            let build = Bundle.applicationBuildVersion
        else {
            return nil
        }
        let format = BuildFlag.isAlpha ?
            "Blockchain-iOS-alpha/%@ (iOS/%@; %@)" :
            "Blockchain-iOS/%@ (iOS/%@; %@)"
        let systemVersion = deviceInfo.systemVersion
        let modelName = deviceInfo.model
        let versionAndBuild = String(format: "%@ b%@", version, build)
        return String(
            format: format,
            versionAndBuild,
            systemVersion,
            modelName
        )
    }
}

protocol NetworkSessionDelegateAPI: AnyObject {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping AuthChallengeHandler
    )
}

class DefaultSessionHandler: NetworkSessionDelegateAPI {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping AuthChallengeHandler
    ) {
        completionHandler(.performDefaultHandling, nil)
    }
}

// swiftlint:disable:next type_name
class BlockchainNetworkCommunicatorSessionHandler: NetworkSessionDelegateAPI {

    @Inject var certificatePinner: CertificatePinnerAPI

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping AuthChallengeHandler
    ) {
        guard BlockchainAPI.shared.shouldPinCertificate else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let host = challenge.protectionSpace.host
        Logger.shared.info("Received challenge from \(host)")

        if BlockchainAPI.PartnerHosts.allCases.contains(where: { $0.rawValue == host }) {
            completionHandler(.performDefaultHandling, nil)
        } else {
            certificatePinner.didReceive(challenge, completion: completionHandler)
        }
    }
}

protocol SessionDelegateAPI: URLSessionDelegate {
    var delegate: NetworkSessionDelegateAPI? { get set }
}

class SessionDelegate: NSObject, SessionDelegateAPI {
    weak var delegate: NetworkSessionDelegateAPI?

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        delegate?.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}

public typealias AuthChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void

public typealias URLParameters = [String: Any]

public typealias URLHeaders = [String: String]

extension HTTPMethod {
    var networkRequestMethod: NetworkRequest.NetworkMethod {
        switch self {
        case .get:
            return NetworkRequest.NetworkMethod.get
        case .post:
            return NetworkRequest.NetworkMethod.post
        case .put:
            return NetworkRequest.NetworkMethod.put
        case .patch:
            return NetworkRequest.NetworkMethod.patch
        case .delete:
            return NetworkRequest.NetworkMethod.delete
        }
    }
}

extension Bool {
    var encoded: String {
        self ? "true" : "false"
    }
}
