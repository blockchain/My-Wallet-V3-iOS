//
//  ERC20BridgeAPI.swift
//  ERC20Kit
//
//  Created by Jack on 31/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import EthereumKit

public protocol ERC20BridgeAPI: class {
    var erc20TokenAccounts: Single<[ERC20TokenAccount]> { get }
    
    func save(erc20TokenAccounts: [ERC20TokenAccount]) -> Completable
    func memo(for transactionHash: String, tokenContractAddress: String) -> Single<String?>
    func save(transactionMemo: String, for transactionHash: String, tokenContractAddress: String) -> Completable
}
