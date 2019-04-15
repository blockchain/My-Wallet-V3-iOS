//
//  ERC20AssetAccountDetailsService.swift
//  ERC20KitTests
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import EthereumKit

public class ERC20AssetAccountDetailsService: AssetAccountDetailsAPI {
    public typealias AccountDetails = ERC20AssetAccountDetails
    
    // TODO:
    // * Create ERC20 bridge
    public typealias Bridge = EthereumWalletBridgeAPI

    private let bridge: Bridge
    private let paxAccountService: PaxAccountAPIClientAPI

    public init(with bridge: Bridge, paxAccountClient: PaxAccountAPIClientAPI) {
        self.bridge = bridge
        self.paxAccountService = paxAccountClient
    }

    public func accountDetails(for accountID: AccountID) -> Maybe<AccountDetails> {
        return Maybe.never()
    }
}
