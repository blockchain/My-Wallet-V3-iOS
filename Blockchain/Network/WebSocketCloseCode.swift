//
//  WebSocketCode.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// WebSocket codes related to closing a WebSocket connection
@objc enum WebSocketCloseCode: Int {
    
    case backgroundedApp = 4500
    case loggedOut = 4501
    case decryptedWallet = 4502
    case receivedToSwipeAddress = 4503
    case archiveUnarchive = 4504

    var reason: String? {
        switch self {
        case .backgroundedApp:
            return "User backgrounded app"
        case .loggedOut:
            return "Logged Out"
        case .decryptedWallet:
            return "Decrypted Wallet"
        case .receivedToSwipeAddress:
            return "Received to swipe address"
        case .archiveUnarchive:
            return "Archived or Unarchived"
        }
    }
}
