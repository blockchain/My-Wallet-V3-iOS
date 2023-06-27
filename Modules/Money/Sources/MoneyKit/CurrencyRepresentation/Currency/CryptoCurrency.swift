// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

/// A crypto currency, representing a digital asset.
public struct CryptoCurrency: Currency, Hashable, Codable, Comparable, CustomDebugStringConvertible, Identifiable {

    public let assetModel: AssetModel

    /// Creates a crypto currency.
    ///
    /// If `code` is invalid, this initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - code:                     A crypto currency code.
    ///   - currenciesService: An enabled currencies service.
    public init?(code: String, service: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default) {
        guard let match = service.cryptoCurrency(code: code) else {
            return nil
        }
        self = match
    }

    /// Creates a crypto currency.
    ///
    /// If `AssetModel` is not a crypto currency model, this initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - assetModel: An AssetModel.
    public init?(assetModel: AssetModel) {
        switch assetModel.kind {
        case .fiat:
            return nil
        case .erc20, .celoToken, .coin:
            self.assetModel = assetModel
        }
    }

    /// Creates an ERC-20 crypto currency.
    ///
    /// If `erc20Address` is invalid, this initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - erc20Address:             An ERC-20 contract address.
    ///   - currenciesService: An enabled currencies service.
    public init?(erc20Address: String, service: EnabledCurrenciesServiceAPI) {
        guard let match = service.erc20(contractAddress: erc20Address) else {
            return nil
        }
        self = match
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let cryptoCurrency = CryptoCurrency(code: stringValue, service: EnabledCurrenciesService.default) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported currency \(stringValue)"
            )
        }
        self = cryptoCurrency
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }

    public var id: String { code }

    public var debugDescription: String {
        "CryptoCurrency.\(code)"
    }

    /// Whether the crypto currency is a coin asset.
    public var isCoin: Bool {
        assetModel.kind.isCoin
    }

    /// Whether the crypto currency is an Ethereum ERC-20 asset.
    public var isERC20: Bool {
        assetModel.kind.isERC20
    }

    /// Whether the crypto currency is an Celo Token asset.
    public var isCeloToken: Bool {
        assetModel.kind.isCeloToken
    }

    public func supports(product: AssetModelProduct) -> Bool {
        assetModel.supports(product: product)
    }

    public static let maxDisplayPrecision: Int = 8

    public var name: String {
        assetModel.name
    }

    public var code: String {
        assetModel.code
    }

    public var displayCode: String {
        assetModel.displayCode
    }

    public var displaySymbol: String { displayCode }

    public var precision: Int {
        assetModel.precision
    }

    public var logoURL: URL? {
        assetModel.logoPngUrl
    }

    public var storeExtraPrecision: Int { 0 }

    public var displayPrecision: Int {
        min(CryptoCurrency.maxDisplayPrecision, precision)
    }

    public static func < (lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        lhs.assetModel.sortIndex < rhs.assetModel.sortIndex
    }

    public static func == (lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        lhs.assetModel == rhs.assetModel
    }
}

extension CryptoCurrency {

    public func network(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default
    ) -> EVMNetwork? {
        enabledCurrenciesService.network(for: self)
    }
}

extension CryptoCurrency {
    public static let bitcoin = AssetModel.bitcoin.cryptoCurrency!
    public static let bitcoinCash = AssetModel.bitcoinCash.cryptoCurrency!
    public static let ethereum = AssetModel.ethereum.cryptoCurrency!
    public static let stellar = AssetModel.stellar.cryptoCurrency!
}

extension EnabledCurrenciesServiceAPI {
    fileprivate func cryptoCurrency(code: String) -> CryptoCurrency? {
        allEnabledCryptoCurrencies
            .first(where: { $0.code == code })
    }

    fileprivate func erc20(contractAddress: String) -> CryptoCurrency? {
        allEnabledCryptoCurrencies.first(where: { currency in
            switch currency.assetModel.kind {
            case .erc20(let value, _):
                return value.caseInsensitiveCompare(contractAddress) == .orderedSame
            default:
                return false
            }
        })
    }
}
