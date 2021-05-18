//
//  UIColor+Creative.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// MARK: - Color Palette - Creative Layer
// https://www.figma.com/file/MWCxP6khQHkDZSLEew6mLqcQ/iOS-Visual-consistency-update?node-id=68%3A0
extension UIColor {

    // MARK: Helper

    private class ColorPaletteBundle { }
    private static let colorPaletteBundle = Bundle(for: ColorPaletteBundle.self)
    private static func color(named name: String) -> UIColor {
        UIColor(named: name, in: colorPaletteBundle, compatibleWith: nil)!
    }

    // Crypto

    static let aaveColor = color(named: "Aave")
    static let algo = color(named: "Algorand")
    static let bch = color(named: "BitcoinCash")
    static let btc = color(named: "Bitcoin")
    static let dot = color(named: "Polkadot")
    static let eth = color(named: "Ethereum")
    static let pax = color(named: "Pax")
    static let usdt = color(named: "Tether")
    static let wDGLD = color(named: "wDGLD")
    static let xlm = color(named: "Stellar")
    static let yfi = color(named: "YearnFinance")

    // Tiers

    static let tiersSilver = color(named: "TierSilver")
    static let tiersGold = color(named: "TierGold")
    static let tiersDiamond = color(named: "TierDiamond")

    // Grey Fade

    static let greyFade100 = color(named: "GreyFade100")
    static let greyFade400 = color(named: "GreyFade400")
    static let greyFade600 = color(named: "GreyFade600")
    static let greyFade800 = color(named: "GreyFade800")

    // White Fade

    static let whiteFade100 = color(named: "WhiteFade100")
    static let whiteFade400 = color(named: "WhiteFade400")
    static let whiteFade600 = color(named: "WhiteFade600")
    static let whiteFade800 = color(named: "WhiteFade800")

    // Grey

    static let grey000 = color(named: "Grey000")
    static let grey050 = color(named: "Grey050")
    static let grey100 = color(named: "Grey100")
    static let grey200 = color(named: "Grey200")
    static let grey300 = color(named: "Grey300")
    static let grey400 = color(named: "Grey400")
    static let grey500 = color(named: "Grey500")
    static let grey600 = color(named: "Grey600")
    static let grey700 = color(named: "Grey700")
    static let grey800 = color(named: "Grey800")
    static let grey900 = color(named: "Grey900")

    // Blue

    static let blue000 = color(named: "Blue000")
    static let blue100 = color(named: "Blue100")
    static let blue200 = color(named: "Blue200")
    static let blue300 = color(named: "Blue300")
    static let blue400 = color(named: "Blue400")
    static let blue500 = color(named: "Blue500")
    static let blue600 = color(named: "Blue600")
    static let blue700 = color(named: "Blue700")
    static let blue800 = color(named: "Blue800")
    static let blue900 = color(named: "Blue900")

    // Green

    static let green000 = color(named: "Green000")
    static let green100 = color(named: "Green100")
    static let green200 = color(named: "Green200")
    static let green300 = color(named: "Green300")
    static let green400 = color(named: "Green400")
    static let green500 = color(named: "Green500")
    static let green600 = color(named: "Green600")
    static let green700 = color(named: "Green700")
    static let green800 = color(named: "Green800")
    static let green900 = color(named: "Green900")

    // Red

    static let red000 = color(named: "Red000")
    static let red100 = color(named: "Red100")
    static let red200 = color(named: "Red200")
    static let red300 = color(named: "Red300")
    static let red400 = color(named: "Red400")
    static let red500 = color(named: "Red500")
    static let red600 = color(named: "Red600")
    static let red700 = color(named: "Red700")
    static let red800 = color(named: "Red800")
    static let red900 = color(named: "Red900")

    // Orange

    static let orange000 = color(named: "Orange000")
    static let orange100 = color(named: "Orange100")
    static let orange200 = color(named: "Orange200")
    static let orange300 = color(named: "Orange300")
    static let orange400 = color(named: "Orange400")
    static let orange500 = color(named: "Orange500")
    static let orange600 = color(named: "Orange600")
    static let orange700 = color(named: "Orange700")
    static let orange800 = color(named: "Orange800")
    static let orange900 = color(named: "Orange900")

    // Purple

    static let purple000 = color(named: "Purple000")
    static let purple100 = color(named: "Purple100")
    static let purple200 = color(named: "Purple200")
    static let purple300 = color(named: "Purple300")
    static let purple400 = color(named: "Purple400")
    static let purple500 = color(named: "Purple500")
    static let purple600 = color(named: "Purple600")
    static let purple700 = color(named: "Purple700")
    static let purple800 = color(named: "Purple800")
    static let purple900 = color(named: "Purple900")

    // Teal

    static let teal000 = color(named: "Teal000")
    static let teal100 = color(named: "Teal100")
    static let teal200 = color(named: "Teal200")
    static let teal300 = color(named: "Teal300")
    static let teal400 = color(named: "Teal400")
    static let teal500 = color(named: "Teal500")
    static let teal600 = color(named: "Teal600")
    static let teal700 = color(named: "Teal700")
    static let teal800 = color(named: "Teal800")
    static let teal900 = color(named: "Teal900")
}
