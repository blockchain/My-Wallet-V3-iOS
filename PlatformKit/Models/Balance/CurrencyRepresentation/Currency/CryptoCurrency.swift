//
//  CryptoCurrency.swift
//  PlatformKit
//
//  Created by AlexM on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

/// This is used to distinguish between different types of digital assets.
/// `PlatformKit` should be almost entirely `CryptoCurrency` agnostic however.
/// It's possible that we may move this along with the other `Balance` related
/// models to a separate framework called `BalanceKit`.
/// This should be used a replacement for `AssetType` which is currently defined
/// in the app target.
public enum CryptoCurrency: String, Currency, Codable, CaseIterable, Comparable {
    case bitcoin = "BTC"
    case ethereum = "ETH"
    case bitcoinCash = "BCH"
    case stellar = "XLM"
    case algorand = "ALGO"
    case wDGLD = "WDGLD"
    case pax = "PAX"
    case tether = "USDT"

    /// Initialize with currency code: `BTC`, `ETH`, `BCH`, `XLM`, `PAX`, `ALGO`, `WDGLD`
    public init?(code: String) {
        self.init(rawValue: code.uppercased())
    }
}

// MARK: - Currency

extension CryptoCurrency {

    public static let maxDisplayableDecimalPlaces: Int = {
        Self.allCases.map { $0.maxDisplayableDecimalPlaces }.max() ?? 0
    }()

    public static func < (lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        lhs.integerValue < rhs.integerValue
    }

    // Helper value for `Comparable` conformance.
    private var integerValue: Int {
        switch self {
        case .bitcoin:
            return 0
        case .ethereum:
            return 1
        case .bitcoinCash:
            return 2
        case .stellar:
            return 3
        case .algorand:
            return 4
        case .wDGLD:
            return 5
        case .pax:
            return 6
        case .tether:
            return 7
        }
    }

    /// CryptoCurrency is supported in Receive.
    /// Used whenever we don't have access to the new Account architecture.
    public var hasNonCustodialReceiveSupport: Bool {
        switch self {
        case .algorand:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .pax,
             .stellar,
             .tether,
             .wDGLD:
            return true
        }
    }

    /// CryptoCurrency is supported in Withdrawal.
    /// Used whenever we don't have access to the new Account architecture.
    public var hasNonCustodialWithdrawalSupport: Bool {
        switch self {
        case .algorand:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .pax,
             .stellar,
             .tether,
             .wDGLD:
            return true
        }
    }

    /// CryptoCurrency is supported in Activity
    /// Used whenever we don't have access to the new Account architecture.
    public var hasNonCustodialActivitySupport: Bool {
        switch self {
        case .algorand:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .pax,
             .tether,
             .stellar,
             .wDGLD:
            return true
        }
    }

    /// CryptoCurrency is supported in New Swap
    /// Used whenever we don't have access to the new Account architecture.
    public var hasSwapSupport: Bool {
        switch self {
        case .algorand:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .pax,
             .stellar,
             .tether,
             .wDGLD:
            return true
        }
    }

    /// CryptoCurrency is supported in Legacy Swap
    /// Used whenever we don't have access to the new Account architecture.
    public var hasLegacySwapSupport: Bool {
        switch self {
        case .algorand,
             .tether,
             .wDGLD:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .pax,
             .stellar:
            return true
        }
    }

    /// CryptoCurrency is supported in Legacy Send
    /// Used whenever we don't have access to the new Account architecture.
    public var hasLegacySendSupport: Bool {
        switch self {
        case .algorand,
             .tether,
             .wDGLD:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .pax,
             .stellar:
            return true
        }
    }

    public var name: String {
        switch self {
        case .algorand:
            return "Algorand"
        case .bitcoin:
            return "Bitcoin"
        case .bitcoinCash:
            return "Bitcoin Cash"
        case .ethereum:
            return "Ether"
        case .pax:
            return "USD \(LocalizationConstants.digital)"
        case .stellar:
            return "Stellar"
        case .tether:
            return "Tether"
        case .wDGLD:
            return "Wrapped-DGLD"
        }
    }

    public var symbol: String { code }
    public var displaySymbol: String { displayCode }

    public var code: String { rawValue }
        
    public var displayCode: String {
        switch self {
        case .algorand, .bitcoin, .bitcoinCash, .ethereum, .stellar:
            return code
        case .tether:
            return "USDT"
        case .pax:
            return "USD-D"
        case .wDGLD:
            return "wDGLD"
        }
    }

    public var maxDecimalPlaces: Int {
        switch self {
        case .algorand:
            return 6
        case .bitcoin:
            return 8
        case .bitcoinCash:
            return 8
        case .ethereum:
            return 18
        case .pax:
            return 18
        case .stellar:
            return 7
        case .tether:
            return 6
        case .wDGLD:
            return 8
        }
    }

    public var maxDisplayableDecimalPlaces: Int {
        switch self {
        case .algorand:
            return 2
        case .bitcoin:
            return 8
        case .bitcoinCash:
            return 8
        case .ethereum:
            return 8
        case .pax:
            return 8
        case .stellar:
            return 7
        case .tether:
            return 6
        case .wDGLD:
            return 8
        }
    }
    
    /// Returns `true` for any ERC20 asset
    public var isERC20: Bool {
        switch self {
        case .pax, .tether, .wDGLD:
            return true
        case .algorand, .bitcoin, .bitcoinCash, .ethereum, .stellar:
            return false
        }
    }
}
