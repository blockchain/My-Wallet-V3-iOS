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
final class BlockchainAPI: NSObject {

    // MARK: - Properties

    /// The instance variable used to access functions of the `API` class.
    static let shared = BlockchainAPI()

    // TODO: remove once migration is complete
    /// Objective-C compatible class function
    @objc class func sharedInstance() -> BlockchainAPI {
        return BlockchainAPI.shared
    }

    /**
     Public endpoints used for Blockchain API calls.
     - Important: Do not use `blockchainAPI` and `blockchainWallet` for API calls.
     Instead, retrieve the wallet and API hostname from the main Bundle in the URL
     extension of this class.
     */
    enum Hosts: String, RawValued {
        case blockchainAPI  = "api.blockchain.info"
        case blockchainDotInfo = "blockchain.info"
        case blockchainDotCom = "blockchain.com"
    }

    /// Public hosts used for partner API calls.
    enum PartnerHosts: String, RawValued {
        case blockchair = "blockchair.com"
        case coinify = "app-api.coinify.com"
        case etherscan = "etherscan.io"
        // TODO: determine correct stellar explorer URL
        case stellarExplorer = "stellar-explorer-placeholder"
        case googleAnalytics = "www.google-analytics.com"
        case iSignThis = "verify.isignthis.com"
        case sfox = "api.sfox.com"
        case sfoxKYC = "sfox-kyc.s3.amazonaws.com"
        case sfoxQuotes = "quotes.sfox.com"
        case shapeshift = "shapeshift.io"
    }

    struct Parameters {
        /// The API code to be used when making network calls to the Blockchain API
        static let apiCode = "1770d5d9-bcea-4d28-ad21-6cbd5be018a8"
    }

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        super.init()
    }

    // MARK: - Temporary Objective-C bridging functions

    // TODO: remove these once migration is complete
    @objc func blockchainAPI() -> String {
        return Hosts.blockchainAPI.rawValue
    }
    @objc func blockchainDotInfo() -> String {
        return Hosts.blockchainDotInfo.rawValue
    }
    @objc func blockchainDotCom() -> String {
        return Hosts.blockchainDotCom.rawValue
    }
    @objc func blockchair() -> String {
        return PartnerHosts.blockchair.rawValue
    }
    @objc func coinify() -> String {
        return PartnerHosts.coinify.rawValue
    }
    @objc func etherscan() -> String {
        return PartnerHosts.etherscan.rawValue
    }
    @objc func googleAnalytics() -> String {
        return PartnerHosts.googleAnalytics.rawValue
    }
    @objc func iSignThis() -> String {
        return PartnerHosts.iSignThis.rawValue
    }
    @objc func sfox() -> String {
        return PartnerHosts.sfox.rawValue
    }
    @objc func sfoxKYC() -> String {
        return PartnerHosts.sfoxKYC.rawValue
    }
    @objc func sfoxQuotes() -> String {
        return PartnerHosts.sfoxQuotes.rawValue
    }
    @objc func shapeshift() -> String {
        return PartnerHosts.shapeshift.rawValue
    }
}
