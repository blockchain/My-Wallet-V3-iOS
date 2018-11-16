//
//  StellarConfiguration.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

private struct HorizonServer {
    static let production = "https://horizon.stellar.org"
    static let test = "https://horizon-testnet.stellar.org"
}

public struct StellarConfiguration {
    public let sdk: StellarSDK
    public let network: Network
}

public extension StellarConfiguration {
    public static let production = StellarConfiguration(
        sdk: StellarSDK(withHorizonUrl: HorizonServer.production),
        network: Network.public
    )
    
    public static let test = StellarConfiguration(
        sdk: StellarSDK(withHorizonUrl: HorizonServer.test),
        network: Network.testnet
    )
}
