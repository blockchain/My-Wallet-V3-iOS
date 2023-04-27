// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

extension AssetModel {
    static func mockERC20(
        symbol: String,
        displaySymbol: String,
        name: String,
        erc20Address: String,
        parentChain: String = "ETH",
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> AssetModel {
        AssetModel(
            code: symbol,
            displayCode: displaySymbol,
            kind: .erc20(contractAddress: erc20Address, parentChain: parentChain),
            name: name,
            precision: precision,
            products: [],
            logoPngUrl: nil,
            spotColor: nil,
            sortIndex: sortIndex
        )
    }

    static func mockCoin(
        symbol: String,
        displaySymbol: String,
        name: String,
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> AssetModel {
        AssetModel(
            code: symbol,
            displayCode: displaySymbol,
            kind: .coin(minimumOnChainConfirmations: 3),
            name: name,
            precision: precision,
            products: [],
            logoPngUrl: nil,
            spotColor: nil,
            sortIndex: sortIndex
        )
    }
}

extension CryptoCurrency {

    static func mockERC20(
        symbol: String = "",
        displaySymbol: String = "",
        name: String = "",
        erc20Address: String = "ETH",
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> CryptoCurrency {
        AssetModel.mockERC20(
            symbol: symbol,
            displaySymbol: displaySymbol,
            name: name,
            erc20Address: erc20Address,
            precision: precision,
            sortIndex: sortIndex
        ).cryptoCurrency!
    }

    static func mockCoin(
        symbol: String = "",
        displaySymbol: String = "",
        name: String = "",
        precision: Int = 18,
        sortIndex: Int = 0
    ) -> CryptoCurrency {
        AssetModel.mockCoin(
            symbol: symbol,
            displaySymbol: displaySymbol,
            name: name,
            precision: precision,
            sortIndex: sortIndex
        ).cryptoCurrency!
    }
}
