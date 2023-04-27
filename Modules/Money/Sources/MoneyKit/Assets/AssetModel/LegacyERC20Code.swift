// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An enumeration of Coin codes that the App supports non-custodial.
public enum NonCustodialCoinCode: String, CaseIterable {
    case bitcoin = "BTC"
    case bitcoinCash = "BCH"
    case ethereum = "ETH"
    case stellar = "XLM"
}

/// An enumeration of the hardcoded ERC20 assets.
/// This shall be removed once we fully support the new `AssetModel` architecture.
public enum ERC20Code: String, CaseIterable {
    case aave = "AAVE"
    case bat = "BAT"
    case comp = "COMP"
    case dai = "DAI"
    case enj = "ENJ"
    case link = "LINK"
    case ogn = "OGN"
    case pax = "PAX"
    case snx = "SNX"
    case sushi = "SUSHI"
    case tbtc = "TBTC"
    case tether = "USDT"
    case uni = "UNI"
    case usdc = "USDC"
    case wbtc = "WBTC"
    case wdgld = "WDGLD"
    case yearnFinance = "YFI"
    case zrx = "ZRX"

    public static func spotColor(code: String) -> String {
        ERC20Code.allCases
            .first(where: { $0.rawValue == code })?
            .spotColor
            ?? "0C6CF2"
    }

    public var spotColor: String {
        switch self {
        case .aave:
            return "2EBAC6"
        case .bat:
            return "FF4724"
        case .comp:
            return "00D395"
        case .dai:
            return "F5AC37"
        case .enj:
            return "624DBF"
        case .link:
            return "2A5ADA"
        case .ogn:
            return "1A82FF"
        case .pax:
            return "00522C"
        case .snx:
            return "00D1FF"
        case .sushi:
            return "FA52A0"
        case .tbtc:
            return "000000"
        case .tether:
            return "26A17B"
        case .uni:
            return "FF007A"
        case .usdc:
            return "2775CA"
        case .wbtc:
            return "FF9B22"
        case .wdgld:
            return "FFE738"
        case .yearnFinance:
            return "0074FA"
        case .zrx:
            return "000000"
        }
    }
}

/// An enumeration of the hardcoded Custodial Coins.
/// This shall be removed once we fully support the new `AssetModel` architecture.
public enum CustodialCoinCode: String, CaseIterable {
    case algorand = "ALGO"
    case bitClout = "CLOUT"
    case blockstack = "STX"
    case dogecoin = "DOGE"
    case eos = "EOS"
    case ethereumClassic = "ETC"
    case litecoin = "LTC"
    case mobileCoin = "MOB"
    case near = "NEAR"
    case polkadot = "DOT"
    case tezos = "XTZ"
    case theta = "THETA"

    public var spotColor: String {
        switch self {
        case .algorand:
            return "000000"
        case .bitClout:
            return "000000"
        case .blockstack:
            return "211F6D"
        case .dogecoin:
            return "C2A633"
        case .eos:
            return "000000"
        case .ethereumClassic:
            return "33FF99"
        case .litecoin:
            return "BFBBBB"
        case .mobileCoin:
            return "243855"
        case .near:
            return "000000"
        case .polkadot:
            return "E6007A"
        case .tezos:
            return "2C7DF7"
        case .theta:
            return "2AB8E6"
        }
    }
}
