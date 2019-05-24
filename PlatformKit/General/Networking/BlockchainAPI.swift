//
//  BlockchainAPI.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Manages URL endpoints and request payloads for the Blockchain API.
 # Usage
 TBD
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
 */

@objc
final public class BlockchainAPI: NSObject {

    // MARK: - Properties

    /// The instance variable used to access functions of the `API` class.
    public static let shared = BlockchainAPI()

    // TODO: remove once migration is complete
    /// Objective-C compatible class function
    @objc public class func sharedInstance() -> BlockchainAPI {
        return BlockchainAPI.shared
    }

    /**
     Public endpoints used for Blockchain API calls.
     - Important: Do not use `blockchainAPI` and `blockchainWallet` for API calls.
     Instead, retrieve the wallet and API hostname from the main Bundle in the URL
     extension of this class.
     */
    public enum Hosts: String {
        case blockchainAPI  = "api.blockchain.info"
        case blockchainDotInfo = "blockchain.info"
        case blockchainDotCom = "blockchain.com"
    }
    
    /// Public hosts used for partner API calls.
    public enum PartnerHosts: String, CaseIterable {
        case coinify = "app-api.coinify.com",
        stellarchain = "stellarchain.io",
        googleAnalytics = "www.google-analytics.com",
        iSignThis = "verify.isignthis.com",
        sfox = "api.sfox.com",
        sfoxKYC = "sfox-kyc.s3.amazonaws.com",
        sfoxQuotes = "quotes.sfox.com",
        shapeshift = "shapeshift.io",
        firebaseAnalytics = "app-measurement.com"
    }

    public struct Parameters {
        /// The API code to be used when making network calls to the Blockchain API
        public static let apiCode = "1770d5d9-bcea-4d28-ad21-6cbd5be018a8"
    }

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        super.init()
    }

    // MARK: - Temporary Objective-C bridging functions

    // TODO: remove these once migration is complete
    @objc public func blockchainAPI() -> String {
        return Hosts.blockchainAPI.rawValue
    }
    @objc public func blockchainDotInfo() -> String {
        return Hosts.blockchainDotInfo.rawValue
    }
    @objc public func blockchainDotCom() -> String {
        return Hosts.blockchainDotCom.rawValue
    }
    @objc public func coinify() -> String {
        return PartnerHosts.coinify.rawValue
    }
    @objc public func etherExplorer() -> String {
        return etherExplorerUrl
    }
    @objc public func bitcoinCashExplorer() -> String {
        return bitcoinCashExplorerUrl
    }
    @objc public func googleAnalytics() -> String {
        return PartnerHosts.googleAnalytics.rawValue
    }
    @objc public func iSignThis() -> String {
        return PartnerHosts.iSignThis.rawValue
    }
    @objc public func sfox() -> String {
        return PartnerHosts.sfox.rawValue
    }
    @objc public func sfoxKYC() -> String {
        return PartnerHosts.sfoxKYC.rawValue
    }
    @objc public func sfoxQuotes() -> String {
        return PartnerHosts.sfoxQuotes.rawValue
    }
    @objc public func shapeshift() -> String {
        return PartnerHosts.shapeshift.rawValue
    }
    
    // MARK: URI
    
    @objc public var webSocketUri: String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    @objc public var ethereumWebSocketUri: String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER_ETH"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    @objc public var bitcoinCashWebSocketUri: String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER_BCH"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    
    // MARK: URL
    
    public var apiHost: String {
        return Bundle.main.infoDictionary!["API_URL"] as! String
    }
    
    @objc public var apiUrl: String {
        return "https://\(apiHost)"
    }
    
    @objc public var walletUrl: String {
        let host = Bundle.main.infoDictionary!["WALLET_SERVER"] as! String
        return "https://\(host)"
    }
    
    @objc public var explorerUrl: String {
        let host = Bundle.main.infoDictionary!["EXPLORER_SERVER"] as! String
        return "https://\(host)"
    }
    
    @objc public var retailCoreUrl: String {
        let host = Bundle.main.infoDictionary!["RETAIL_CORE_URL"] as! String
        return "https://\(host)"
    }
    
    @objc public var retailCoreSocketUrl: String {
        let host = Bundle.main.infoDictionary!["RETAIL_CORE_SOCKET_URL"] as! String
        return "wss://\(host)"
    }
    
    @objc public var walletOptionsUrl: String {
        return "\(walletUrl)/Resources/wallet-options.json"
    }
    
    @objc public var buyWebViewUrl: String? {
        let hostAndPath = Bundle.main.infoDictionary!["BUY_WEBVIEW_URL"] as! String
        return "https://\(hostAndPath)"
    }
    
    @objc public var bitcoinExplorerUrl: String {
        return "\(explorerUrl)/btc"
    }
    
    @objc public var bitcoinCashExplorerUrl: String {
        return "\(explorerUrl)/bch"
    }
    
    @objc public var etherExplorerUrl: String {
        return "\(explorerUrl)/eth"
    }
    
    public var coinifyEndpoint: String {
        let host = Bundle.main.infoDictionary!["COINIFY_URL"] as! String
        return "https://\(host)"
    }
    
    public var stellarchainUrl: String {
        return "https://\(PartnerHosts.stellarchain.rawValue)"
    }
    
    public var pushNotificationsUrl: String {
        return "\(walletUrl)/wallet?method=update-ios"
    }
    
    public var servicePriceUrl: String {
        return "\(apiUrl)/price"
    }
    
    // MARK: - API Endpoints
    
    public var walletSettingsUrl: String {
        return "\(walletUrl)/wallet"
    }
    
    public var signedRetailTokenUrl: String {
        return "\(walletUrl)/wallet/signed-retail-token"
    }
    
    public var pinStore: String {
        return "\(walletUrl)/pin-store"
    }
    
    public enum KYC {
        static var countries: String {
            return BlockchainAPI.shared.apiUrl + "/kyc/config/countries"
        }
    }
    
    public enum Nabu {
        static var quotes: String {
            return BlockchainAPI.shared.retailCoreUrl + "/markets/quotes"
        }
    }
}
