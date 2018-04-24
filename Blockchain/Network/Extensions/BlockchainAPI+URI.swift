//
//  BlockchainAPI+URI.swift
//  Blockchain
//
//  Created by Maurice A. on 4/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension BlockchainAPI {
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
}
