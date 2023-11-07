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
        ERC20Code(rawValue: code)?.spotColor ?? "0C6CF2"
    }

    var spotColor: String {
        switch self {
        case .aave:
            "2EBAC6"
        case .bat:
            "FF4724"
        case .comp:
            "00D395"
        case .dai:
            "F5AC37"
        case .enj:
            "624DBF"
        case .link:
            "2A5ADA"
        case .ogn:
            "1A82FF"
        case .pax:
            "00522C"
        case .snx:
            "00D1FF"
        case .sushi:
            "FA52A0"
        case .tbtc:
            "000000"
        case .tether:
            "26A17B"
        case .uni:
            "FF007A"
        case .usdc:
            "2775CA"
        case .wbtc:
            "FF9B22"
        case .wdgld:
            "FFE738"
        case .yearnFinance:
            "0074FA"
        case .zrx:
            "000000"
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
            "000000"
        case .bitClout:
            "000000"
        case .blockstack:
            "211F6D"
        case .dogecoin:
            "C2A633"
        case .eos:
            "000000"
        case .ethereumClassic:
            "33FF99"
        case .litecoin:
            "BFBBBB"
        case .mobileCoin:
            "243855"
        case .near:
            "000000"
        case .polkadot:
            "E6007A"
        case .tezos:
            "2C7DF7"
        case .theta:
            "2AB8E6"
        }
    }
}
