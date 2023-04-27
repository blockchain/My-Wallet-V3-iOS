// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

/// A crypto currency, representing a digital asset.
public struct CryptoCurrency: Currency, Hashable, Codable, Comparable, CustomDebugStringConvertible, Equatable {

    public let assetModel: AssetModel

    /// Creates a crypto currency.
    ///
    /// If `code` is invalid, this initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - code:                     A crypto currency code.
    ///   - enabledCurrenciesService: An enabled currencies service.
    public init?(code: String, service: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default) {
        guard let cryptoCurrency = service.allEnabledCryptoCurrencies
            .first(where: { $0.code == code })
        else {
            return nil
        }

        self = cryptoCurrency
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
    ///   - enabledCurrenciesService: An enabled currencies service.
    public init?(erc20Address: String, service: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default) {
        guard let cryptoCurrency = service.allEnabledCryptoCurrencies.first(where: { currency in
            switch currency.assetModel.kind {
            case .erc20(let contractAddress, _):
                return contractAddress.caseInsensitiveCompare(erc20Address) == .orderedSame
            default:
                return false
            }
        }) else {
            return nil
        }
        self = cryptoCurrency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let cryptoCurrency = CryptoCurrency(code: stringValue) else {
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
}

// MARK: - Currency

extension CryptoCurrency {

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

extension CryptoCurrency: Identifiable {

    public var id: String { code }
}

extension CryptoCurrency {
    public static let bitcoin = AssetModel.bitcoin.cryptoCurrency!
    public static let bitcoinCash = AssetModel.bitcoinCash.cryptoCurrency!
    public static let ethereum = AssetModel.ethereum.cryptoCurrency!
    public static let stellar = AssetModel.stellar.cryptoCurrency!
    public static let usdt = AssetModel.usdt.cryptoCurrency!
}

#if canImport(BlockchainComponentLibrary)

import BlockchainComponentLibrary

extension CryptoCurrency {

    public var color: Color {
        assetModel.spotColor.map(Color.init(hex:))
            ?? (CustodialCoinCode(rawValue: code)?.spotColor).map(Color.init(hex:))
            ?? Color(hex: ERC20Code.spotColor(code: code))
    }

    public func logo(
        size: Double = 36
    ) -> some View {
        Logo<EmptyView>(currency: self, size: size, overlay: nil)
    }

    public func logo(
        size: Double = 36,
        @ViewBuilder overlay: @escaping () -> some View
    ) -> some View {
        Logo(currency: self, size: size, overlay: overlay)
    }

    public struct Logo<Overlay: View>: View {

        var currency: CryptoCurrency
        var size: Double = 36
        var overlay: (() -> Overlay)?

        public init(
            currency: CryptoCurrency,
            size: Double = 36,
            overlay: (() -> Overlay)? = nil
        ) {
            self.currency = currency
            self.size = size
            self.overlay = overlay
        }

        public var body: some View {
            ZStack {
                AsyncMedia(url: currency.assetModel.logoPngUrl)
                    .frame(width: size - 4, height: size - 4)
                    .overlay(overlaid)
            }
            .frame(width: size, height: size)
        }

        @ViewBuilder var overlaid: some View {
            if let overlay {
                ZStack(alignment: .bottomTrailing) {
                    Color.clear
                    Circle()
                        .fill(Color.semantic.background)
                        .inscribed(overlay())
                        .frame(width: size / 3, height: size / 3)
                }
            }
        }
    }
}

#endif
