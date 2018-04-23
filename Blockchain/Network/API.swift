//
//  API.swift
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
final class API: NSObject {

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
    @objc func blockchainAPI() -> NSString {
        return Endpoints.blockchainAPI.rawValue as NSString
    }
    @objc func blockchainWallet() -> NSString {
        return Endpoints.blockchainWallet.rawValue as NSString
    }
    @objc func blockchair() -> NSString {
        return Endpoints.blockchair.rawValue as NSString
    }
    @objc func coinify() -> NSString {
        return Endpoints.coinify.rawValue as NSString
    }
    @objc func etherscan() -> NSString {
        return Endpoints.etherscan.rawValue as NSString
    }
    @objc func googleAnalytics() -> NSString {
        return Endpoints.googleAnalytics.rawValue as NSString
    }
    @objc func iSignThis() -> NSString {
        return Endpoints.iSignThis.rawValue as NSString
    }
    @objc func sfox() -> NSString {
        return Endpoints.sfox.rawValue as NSString
    }
    @objc func sfoxKYC() -> NSString {
        return Endpoints.sfoxKYC.rawValue as NSString
    }
    @objc func sfoxQuotes() -> NSString {
        return Endpoints.sfoxQuotes.rawValue as NSString
    }
    @objc func shapeshift() -> NSString {
        return Endpoints.shapeshift.rawValue as NSString
    }
}

protocol Enumeratable: Hashable {
    static var cases: [Self] { get }
}

extension Enumeratable {
    static var cases: [Self] {
        var cases: [Self] = []
        var index = 0
        for element: Self in AnyIterator({
            let item = withUnsafeBytes(of: &index) { $0.load(as: Self.self) }
            guard item.hashValue == index else { return nil }
            index += 1
            return item
        }) {
            cases.append(element)
        }
        return cases
    }
}

protocol RawValued: Hashable, RawRepresentable {
    static var rawValues: [RawValue] { get }
}

extension RawValued {
    static var rawValues: [RawValue] {
        var rawValues: [RawValue] = []
        var index = 0
        for element: Self in AnyIterator({
            let item = withUnsafeBytes(of: &index) { $0.load(as: Self.self) }
            guard item.hashValue == index else { return nil }
            index += 1
            return item
        }) {
            rawValues.append(element.rawValue)
        }
        return rawValues
    }
}
