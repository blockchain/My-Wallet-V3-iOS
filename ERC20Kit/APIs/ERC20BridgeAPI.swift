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
    var isWaitingOnEtherTransaction: Single<Bool> { get }
    
    var erc20TokenAccounts: Single<[String: ERC20TokenAccount]> { get }
   
    func tokenAccount(for key: String) -> Single<ERC20TokenAccount?>
    func save(erc20TokenAccounts: [String: ERC20TokenAccount]) -> Completable
    func memo(for transactionHash: String, tokenKey: String) -> Single<String?>
    func save(transactionMemo: String, for transactionHash: String, tokenKey: String) -> Completable
}
