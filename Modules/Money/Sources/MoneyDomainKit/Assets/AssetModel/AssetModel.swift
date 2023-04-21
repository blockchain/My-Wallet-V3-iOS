// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

/// An asset (crypto or fiat).
public struct AssetModel: Hashable {

    // MARK: - Public Properties

    /// The asset code (e.g. `USD`, `BTC`, etc.).
    public let code: String
    /// The asset display code (e.g. `USD`, `BTC`, etc.).
    public let displayCode: String
    /// The asset type.
    public let kind: AssetModelType
    /// The asset name (e.g. `US Dollar`, `Bitcoin`, etc.).
    public let name: String
    /// The asset precision, representing the maximum number of fraction digits.
    public let precision: Int
    /// The list of supported asset products.
    public let products: [AssetModelProduct]
    /// The URL to the asset logo.
    public let logoPngUrl: URL?
    /// The asset spot color.
    public let spotColor: String?

    // MARK: - Internal Properties

    /// Temporary sorting index, while full dynamic asset migration is in progress.
    let sortIndex: Int

    // MARK: - Setup

    public init(
        code: String,
        displayCode: String,
        kind: AssetModelType,
        name: String,
        precision: Int,
        products: [AssetModelProduct],
        logoPngUrl: URL?,
        spotColor: String?,
        sortIndex: Int
    ) {
        self.code = code
        self.displayCode = displayCode
        self.kind = kind
        self.name = name
        self.precision = precision
        self.products = products
        self.logoPngUrl = logoPngUrl
        self.spotColor = spotColor
        self.sortIndex = sortIndex
    }

    // MARK: - Internal Methods

    /// Creates a new AssetModel asset by replacing the current list of supported asset products.
    ///
    /// - Parameter products: A list of supported asset products.
    func with(products: [AssetModelProduct]) -> AssetModel {
        AssetModel(
            code: code,
            displayCode: displayCode,
            kind: kind,
            name: name,
            precision: precision,
            products: products,
            logoPngUrl: logoPngUrl,
            spotColor: spotColor,
            sortIndex: sortIndex
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }

    public func supports(product: AssetModelProduct) -> Bool {
        products.contains(product)
    }
}

extension AssetModel {

    public var cryptoCurrency: CryptoCurrency? {
        CryptoCurrency(assetModel: self)
    }

    public static let bitcoin = AssetModel(
        code: "BTC",
        displayCode: "BTC",
        kind: .coin(minimumOnChainConfirmations: 2),
        name: "Bitcoin",
        precision: 8,
        products: [.custodialWalletBalance, .interestBalance, .mercuryDeposits, .mercuryWithdrawals, .privateKey, .activeRewardsBalance],
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/bitcoin/info/logo.png"),
        spotColor: "FF9B22",
        sortIndex: 1
    )

    public static let bitcoinCash = AssetModel(
        code: "BCH",
        displayCode: "BCH",
        kind: .coin(minimumOnChainConfirmations: 3),
        name: "Bitcoin Cash",
        precision: 8,
        products: [.custodialWalletBalance, .interestBalance, .mercuryDeposits, .mercuryWithdrawals, .privateKey],
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/bitcoincash/info/logo.png"),
        spotColor: "8DC351",
        sortIndex: 3
    )

    public static let ethereum = AssetModel(
        code: "ETH",
        displayCode: "ETH",
        kind: .coin(minimumOnChainConfirmations: 30),
        name: "Ethereum",
        precision: 18,
        products: [.custodialWalletBalance, .interestBalance, .mercuryDeposits, .mercuryWithdrawals, .privateKey, .stakingBalance],
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/ethereum/info/logo.png"),
        spotColor: "473BCB",
        sortIndex: 2
    )

    public static let stellar = AssetModel(
        code: "XLM",
        displayCode: "XLM",
        kind: .coin(minimumOnChainConfirmations: 3),
        name: "Stellar",
        precision: 7,
        products: [.custodialWalletBalance, .interestBalance, .mercuryDeposits, .mercuryWithdrawals, .privateKey],
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/stellar/info/logo.png"),
        spotColor: "000000",
        sortIndex: 4
    )

    public static let usdt = AssetModel(
        code: "USDT",
        displayCode: "USDT",
        kind: .coin(minimumOnChainConfirmations: 3),
        name: "Tether",
        precision: 7,
        products: [.custodialWalletBalance, .interestBalance, .mercuryDeposits, .mercuryWithdrawals, .privateKey],
        logoPngUrl: URL("https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png"),
        spotColor: "000000",
        sortIndex: 4
    )

}
