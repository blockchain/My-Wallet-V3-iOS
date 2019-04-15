//
//  ERC20WalletAccountRepository.swift
//  ERC20KitTests
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

// TODO
// * make all this generic

public class ERC20WalletAccountRepository: WalletAccountRepositoryAPI {
    public typealias Account = ERC20WalletAccount
    
//    public typealias Bridge = EthereumWalletBridgeAPI // TODO
    
    // MARK: - Properties
    
    // For ETH, there is only one account which is the default account.
    public var defaultAccount: Account?
    
//    fileprivate let bridge: Bridge
//
//    // MARK: - Init
//
//    public init(with bridge: Bridge) {
//        self.bridge = bridge
//    }
    
    // MARK: - Public methods

    public func accounts() -> [Account] {
        guard let defaultAccount = defaultAccount else {
            return []
        }
        return [ defaultAccount ]
    }
}
