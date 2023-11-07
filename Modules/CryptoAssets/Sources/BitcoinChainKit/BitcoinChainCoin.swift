// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit
import WalletCore

public enum BitcoinChain {
    static let chainQueue: String = "chain.queue"
}

public enum BitcoinChainCoin: String {
    case bitcoin = "BTC"
    case bitcoinCash = "BCH"

    public var cryptoCurrency: CryptoCurrency {
        switch self {
        case .bitcoin:
            .bitcoin
        case .bitcoinCash:
            .bitcoinCash
        }
    }

    public var dust: BigInt {
        switch self {
        case .bitcoin,
             .bitcoinCash:
            546
        }
    }

    public var uriScheme: String {
        switch self {
        case .bitcoin:
            "bitcoin"
        case .bitcoinCash:
            "bitcoincash"
        }
    }

    /// Unsigned integer value to be used for the 'coin type' field when deriving a Blockchain.com wallet for this token.
    public var derivationCoinType: UInt32 {
        switch self {
        case .bitcoin:
            0
        case .bitcoinCash:
            0
        }
    }
}

public protocol BitcoinChainToken {
    static var coin: BitcoinChainCoin { get }
}

public struct BitcoinToken: BitcoinChainToken {
    public static let coin: BitcoinChainCoin = .bitcoin
}

public struct BitcoinCashToken: BitcoinChainToken {
    public static let coin: BitcoinChainCoin = .bitcoinCash
}

extension BitcoinChainCoin {
    /// WalletCore CoinType for the associated Token.
    var walletCoreCoinType: WalletCore.CoinType {
        switch self {
        case .bitcoin:
            .bitcoin
        case .bitcoinCash:
            .bitcoinCash
        }
    }
}
