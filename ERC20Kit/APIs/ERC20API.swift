//
//  ERC20API.swift
//  ERC20Kit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import RxSwift
import PlatformKit
import EthereumKit

public protocol ERC20API {
    associatedtype Token: ERC20Token
    
    func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate>
}
