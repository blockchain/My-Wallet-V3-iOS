// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class BlockchainAPI {

    // MARK: - Static Properties

    /// The instance variable used to access functions of the `API` class.
    public static let shared = BlockchainAPI(credentialProvider: NetworkCredentialProvider())

    // MARK: - Types

    /// Public hosts used for partner API calls.
    public enum PartnerHosts: String, CaseIterable {
        case bitpay = "bitpay.com"
        case stellarchain = "stellarchain.io"
        case googleAnalytics = "www.google-analytics.com"
        case shapeshift = "shapeshift.io"
        case firebaseAnalytics = "app-measurement.com"
        case blockchainStatus = "blockchain-status.com"
        case everyPayCOM = "every-pay.com"
        case everyPayEU = "every-pay.eu"
    }

    public enum Parameters {
        /// The API code to be used when making network calls to the Blockchain API
        public static let apiCode = "35e77459-723f-48b0-8c9e-6e9e8f54fbd3"
    }

    // MARK: - Properties

    private let credentialProvider: NetworkCredentialProviderAPI

    // MARK: - Initialization

    private init(credentialProvider: NetworkCredentialProviderAPI) {
        self.credentialProvider = credentialProvider
    }

    // MARK: - Public Properties

    public var swiftyBeaverAppID: String {
        credentialProvider.swiftyBeaverAppId
    }

    public var swiftyBeaverAppSecret: String {
        credentialProvider.swiftyBeaverAppSecret
    }

    public var swiftyBeaverAppKey: String {
        credentialProvider.swiftyBeaverAppKey
    }

    public var apiUrl: String {
        "https://\(apiHost)"
    }

    public var walletUrl: String {
        "https://\(walletHost)"
    }

    public var retailCoreUrl: String {
        "https://\(credentialProvider.retailCoreURL)"
    }

    public var exchangeURL: String {
        "https://\(credentialProvider.exchangeURL)"
    }

    public var walletOptionsUrl: String {
        "\(walletUrl)/Resources/wallet-options.json"
    }

    public var bitcoinExplorerUrl: String {
        "\(explorerUrl)/btc"
    }

    public var bitcoinCashExplorerUrl: String {
        "\(explorerUrl)/bch"
    }

    public var etherExplorerUrl: String {
        "\(explorerUrl)/eth"
    }

    public var stellarchainUrl: String {
        "https://\(PartnerHosts.stellarchain.rawValue)"
    }

    public var pushNotificationsUrl: String {
        "\(walletUrl)/wallet?method=update-firebase"
    }

    public var walletSettingsUrl: String {
        "\(walletUrl)/wallet"
    }

    public var pinStore: String {
        "\(walletUrl)/pin-store"
    }

    // MARK: - Properties

    var shouldPinCertificate: Bool {
        let value: String = credentialProvider.certificatePinning
        switch value {
        case "1":
            return true
        case "0":
            return false
        default:
            return true
        }
    }

    var apiHost: String {
        credentialProvider.apiURL
    }

    var walletHost: String {
        credentialProvider.walletServer
    }

    var everyPayHost: String {
        credentialProvider.everyPayURL
    }

    var explorerHost: String {
        credentialProvider.explorerServer
    }

    // MARK: - Private Properties

    private var explorerUrl: String {
        "https://\(explorerHost)"
    }
}
