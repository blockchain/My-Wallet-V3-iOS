//
//  StellarOperationsStreamAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

/// The SDK provides a way to stream operations given a user's accountID.
/// That said, you shouldn't use this as a replacement for fetching the operations.
/// You should initially fetch the operations and then begin streaming given the
/// last identifier/cursor of the item that you received.
/// Note that sometimes you will receive an error from the streaming API.
/// Despite receiving an error (on testnet) I still have received operations
/// after the fact. 
protocol StellarOperationsStreamAPI {
    
    var stream: OperationsStreamItem? { get set }
    var service: stellarsdk.OperationsService { get set }
    
    func stream(accountID: String, token: String?)
    func end()
}
