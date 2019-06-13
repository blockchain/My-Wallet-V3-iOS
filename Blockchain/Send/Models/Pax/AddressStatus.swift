//
//  AddressStatus.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import EthereumKit

enum AddressStatus {
    case valid(EthereumAccountAddress)
    case invalid
    case empty
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        default:
            return false
        }
    }
    
    var address: EthereumAccountAddress? {
        switch self {
        case .valid(let address):
            return address
        default:
            return nil
        }
    }
}
