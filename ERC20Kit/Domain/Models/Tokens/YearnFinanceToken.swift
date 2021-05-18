//
//  YearnFinanceToken.swift
//  ERC20Kit
//
//  Created by Paulo on 24/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import EthereumKit
import PlatformKit

public struct YearnFinanceToken: ERC20Token {
    public static let nonCustodialTransactionSupport: AvailableActions = [.swap]
    public static let legacySendSupport: Bool = false
    public static let assetType: CryptoCurrency = .yearnFinance
    public static let contractAddress: EthereumContractAddress = "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e"

    //swiftlint:disable:next force_try
    public static let smallestSpendableValue: ERC20TokenValue<Self> = try! ERC20TokenValue<Self>(
        crypto: CryptoValue.create(minor: 1, currency: assetType)
    )
}
