//
//  ERC20AccountAPIClientMock.swift
//  ERC20KitTests
//
//  Created by Jack on 23/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import BigInt
import PlatformKit
import EthereumKit
@testable import ERC20Kit

class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {
    typealias Token = PaxToken
    
    static let balance = CryptoValue.paxFromMajor(decimal: Decimal(2.0)).amount
        .string(unitDecimals: 0)
    static let accountResponse = ERC20AccountResponse<PaxToken>(
        accountHash: "",
        tokenHash: "",
        balance: balance,
        decimals: 0
    )
    
    var fetchWalletAccountResponse = Single<ERC20AccountResponse<PaxToken>>.just(accountResponse)
    func fetchWalletAccount(ethereumAddress: String) -> Single<ERC20AccountResponse<PaxToken>> {
        return fetchWalletAccountResponse
    }
}
