//
//  AaveToken.swift
//  ERC20Kit
//
//  Created by Paulo on 24/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import EthereumKit
import PlatformKit

public struct AaveToken: ERC20Token {
    public static let nonCustodialTransactionSupport: AvailableActions = [.swap]
    public static let legacySendSupport: Bool = false
    public static let assetType: CryptoCurrency = .aave
    public static let contractAddress: EthereumContractAddress = "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9"

    //swiftlint:disable:next force_try
    public static let smallestSpendableValue: ERC20TokenValue<Self> = try! ERC20TokenValue<Self>(
        crypto: CryptoValue.create(major: "0.01", currency: assetType)!
    )
}

