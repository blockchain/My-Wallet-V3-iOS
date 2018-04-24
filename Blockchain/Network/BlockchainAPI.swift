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
class BlockchainAPI: NSObject {

    // MARK: - Properties

    /// The instance variable used to access functions of the `API` class.
    static let shared = API()

    // TODO: remove once migration is complete
    /// Objective-C compatible class function
    @objc class func sharedInstance() -> API {
        return API.shared
    }

    /**
     Stores public endpoints used for API calls.
     - Important: Do not use `blockchainAPI` and `blockchainWallet` for API calls.
     Instead, retrieve the wallet and API hostname from the main Bundle in the URL
     extension of this class.
     */

    enum Endpoints: String, RawValued {
        case blockchainAPI  = "api.blockchain.info"
        case blockchainWallet = "blockchain.info"
    }

    enum PartnerEndpoints: String, RawValued {
        case blockchair = "blockchair.com"
        case coinify = "app-api.coinify.com"
        case etherscan = "etherscan.io"
        case googleAnalytics = "www.google-analytics.com"
        case iSignThis = "verify.isignthis.com"
        case sfox = "api.sfox.com"
        case sfoxKYC = "sfox-kyc.s3.amazonaws.com"
        case sfoxQuotes = "quotes.sfox.com"
        case shapeshift = "shapeshift.io"
    }

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        super.init()
    }

    // MARK: - Temporary Objective-C bridging functions

    // TODO: remove these once migration is complete
    @objc func blockchainAPI() -> String {
        return Endpoints.blockchainAPI.rawValue
    }
    @objc func blockchainWallet() -> String {
        return Endpoints.blockchainWallet.rawValue
    }
    @objc func blockchair() -> String {
        return Endpoints.blockchair.rawValue
    }
    @objc func coinify() -> String {
        return Endpoints.coinify.rawValue
    }
    @objc func etherscan() -> String {
        return Endpoints.etherscan.rawValue
    }
    @objc func googleAnalytics() -> String {
        return Endpoints.googleAnalytics.rawValue
    }
    @objc func iSignThis() -> String {
        return Endpoints.iSignThis.rawValue
    }
    @objc func sfox() -> String {
        return Endpoints.sfox.rawValue
    }
    @objc func sfoxKYC() -> String {
        return Endpoints.sfoxKYC.rawValue
    }
    @objc func sfoxQuotes() -> String {
        return Endpoints.sfoxQuotes.rawValue
    }
    @objc func shapeshift() -> String {
        return Endpoints.shapeshift.rawValue
    }
}
