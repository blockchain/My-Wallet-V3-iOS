//
//  EthereumHistoricalTransactionService.swift
//  EthereumKit
//
//  Created by Jack on 27/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift

public final class EthereumHistoricalTransactionService: HistoricalTransactionAPI {
    
    public typealias Bridge = EthereumWalletBridgeAPI & EthereumWalletTransctionsBridgeAPI
    
    // MARK: - Properties
    
    private let bridge: Bridge

    // MARK: - Init
    
    public init(with bridge: Bridge) {
        self.bridge = bridge
    }
    
    public func fetchTransactions() -> Single<[EthereumHistoricalTransaction]> {
        return bridge.transactions
    }
}
