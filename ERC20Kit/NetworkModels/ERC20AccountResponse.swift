//
//  ERC20AccountResponse.swift
//  ERC20Kit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct ERC20AccountResponse<Token: ERC20Token>: Decodable {
    let accountHash: String
    let tokenHash: String
    let balance: String
    let decimals: Int
    
    public init(
        accountHash: String,
        tokenHash: String,
        balance: String,
        decimals: Int) {
        self.accountHash = accountHash
        self.tokenHash = tokenHash
        self.balance = balance
        self.decimals = decimals
    }
}
