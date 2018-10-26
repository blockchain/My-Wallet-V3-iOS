//
//  StellarConfiguration.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

private struct HorizonServer {
    static let production = "https://horizon.stellar.org"
    static let test = "https://horizon-testnet.stellar.org"
}

struct StellarConfiguration {
    let sdk: StellarSDK
    let network: Network
}

extension StellarConfiguration {
    static let production = StellarConfiguration(
        sdk: StellarSDK(withHorizonUrl: HorizonServer.production),
        network: Network.public
    )
    
    static let test = StellarConfiguration(
        sdk: StellarSDK(withHorizonUrl: HorizonServer.test),
        network: Network.testnet
    )
}
