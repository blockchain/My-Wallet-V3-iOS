//
//  URL.swift
//  Blockchain
//
//  Created by Maurice A. on 4/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension API {
    var apiUrl: String? {
        guard let host = Bundle.main.infoDictionary!["API_URL"] as? String else {
            return nil
        }
        return "https://\(host)"
    }
    var walletUrl: String? {
        guard let host = Bundle.main.infoDictionary!["WALLET_SERVER"] as? String else {
            return nil
        }
        return "https://\(host)"
    }
    var webSocketUri: String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    var ethereumWebSocketUri: String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER_ETH"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    var bitcoinCashWebSocketUri: String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["WEBSOCKET_SERVER_BCH"] as? String else {
            return nil
        }
        return "wss://\(hostAndPath)"
    }
    var buyWebViewUrl: String? {
        guard let hostAndPath = Bundle.main.infoDictionary!["BUY_WEBVIEW_URL"] as? String else {
            return nil
        }
        return "https://\(hostAndPath)"
    }
    var blockchairUrl: String {
        return "https://\(Endpoints.blockchair.rawValue)"
    }
    var blockchairBchTransactionUrl: String {
        return  "\(blockchairUrl)/bitcoin-cash/transaction/"
    }
    var etherscanUrl: String {
        return "https://\(Endpoints.etherscan.rawValue)"
    }
}
