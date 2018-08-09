//
//  BlockchainAPI+URL.swift
//  Blockchain
//
//  Created by Maurice A. on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension BlockchainAPI {
    var apiUrl: String {
        let host = Bundle.main.infoDictionary!["API_URL"] as! String
        return "https://\(host)"
    }

    var walletUrl: String {
        let host = Bundle.main.infoDictionary!["WALLET_SERVER"] as! String
        return "https://\(host)"
    }
    
    var kycCredentials: String {
        let host = Bundle.main.infoDictionary!["KYC_ENDPOINT"] as! String
        return "https://\(host)"
    }

    var walletOptionsUrl: String {
        return "\(walletUrl)/Resources/wallet-options.json"
    }

    var buyWebViewUrl: String? {
        let hostAndPath = Bundle.main.infoDictionary!["BUY_WEBVIEW_URL"] as! String
        return "https://\(hostAndPath)"
    }

    var blockchairUrl: String {
        return "https://\(PartnerHosts.blockchair.rawValue)"
    }

    var etherscanUrl: String {
        return "https://\(PartnerHosts.etherscan.rawValue)"
    }

    var pushNotificationsUrl: String {
        return "\(walletUrl)/wallet?method=update-ios"
    }

    // MARK: - API Endpoints

    var pinStore: String {
        return "\(walletUrl)/pin-store"
    }

    enum KYC {
        static var countries: String {
            return BlockchainAPI.shared.apiUrl + "/kyc/config/countries"
        }
    }
}
