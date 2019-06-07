//
//  WalletOptions.swift
//  Blockchain
//
//  Created by kevinwu on 6/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

private struct Keys {
    static let partners = "partners"
    static let coinify = "coinify"
    static let partnerId = "partnerId"
    static let countries = "countries"
    static let mobile = "mobile"
    static let walletRoot = "walletRoot"
    static let maintenance = "maintenance"
    static let mobileInfo = "mobileInfo"
    static let shapeshift = "shapeshift"
    static let ios = "ios"
    static let xlm = "xlm"
}

typealias JSON = [String: Any]

// TODO: Conform to Decodable
struct WalletOptions {

    // MARK: - Internal Structs

    struct Mobile {
        let walletRoot: String?
    }

    struct MobileInfo {
        let message: String?
    }

    struct Shapeshift {
        let countriesBlacklist: [String]?
        let statesWhitelist: [String]?
    }

    struct IosConfig {
        let showShapeshift: Bool
    }
    
    struct Coinify {
        let partnerId: Int
        let countries: [String]
    }
    
    struct XLMMetadata {
        let operationFee: Int
        let sendTimeOutSeconds: Int
    }

    // MARK: - Properties

    let downForMaintenance: Bool

    let mobileInfo: MobileInfo?

    let mobile: Mobile?

    let shapeshift: Shapeshift?

    let iosConfig: IosConfig?
    
    let coinifyMetadata: Coinify?
    
    let xlmMetadata: XLMMetadata?
}

extension WalletOptions.Coinify {
    init?(json: JSON) {
        if let partners = json[Keys.partners] as? [String: [String: Any]] {
            guard let coinify = partners[Keys.coinify] else { return nil }
            guard let identifier = coinify[Keys.partnerId] as? Int else { return nil }
            guard let countries = coinify[Keys.countries] as? [String] else { return nil }
            self.partnerId = identifier
            self.countries = countries
        } else {
            return nil
        }
    }
}

extension WalletOptions.XLMMetadata {
    init?(json: JSON) {
        if let xlmData = json[Keys.xlm] as? [String: Int] {
            guard let fee = xlmData["operationFee"] else { return nil }
            guard let timeout = xlmData["sendTimeOutSeconds"] else { return nil }
            self.operationFee = fee
            self.sendTimeOutSeconds = timeout
        } else {
            return nil
        }
    }
}

extension WalletOptions.Mobile {
    init(json: JSON) {
        if let mobile = json[Keys.mobile] as? [String: String] {
            self.walletRoot = mobile[Keys.walletRoot]
        } else {
            self.walletRoot = nil
        }
    }
}

extension WalletOptions.MobileInfo {
    init(json: JSON) {
        if let mobileInfo = json[Keys.mobileInfo] as? [String: String] {
            if let code = Locale.current.languageCode {
                self.message = mobileInfo[code] ?? mobileInfo["en"]
            } else {
                self.message = mobileInfo["en"]
            }
        } else {
            self.message = nil
        }
    }
}

extension WalletOptions.Shapeshift {
    init(json: JSON) {
        guard let shapeshiftJson = json[Keys.shapeshift] as? JSON else {
            self.countriesBlacklist = nil
            self.statesWhitelist = nil
            return
        }
        self.countriesBlacklist = shapeshiftJson["countriesBlacklist"] as? [String]
        self.statesWhitelist = shapeshiftJson["statesWhitelist"] as? [String]
    }
}

extension WalletOptions.IosConfig {
    init?(json: JSON) {
        guard let iosJson = json[Keys.ios] as? JSON else {
            return nil
        }
        self.showShapeshift = iosJson["showShapeshift"] as? Bool ?? false
    }
}

extension WalletOptions {
    init(json: JSON) {
        self.downForMaintenance = json[Keys.maintenance] as? Bool ?? false
        self.mobile = WalletOptions.Mobile(json: json)
        self.mobileInfo = WalletOptions.MobileInfo(json: json)
        self.shapeshift = WalletOptions.Shapeshift(json: json)
        self.iosConfig = WalletOptions.IosConfig(json: json)
        self.coinifyMetadata = WalletOptions.Coinify(json: json)
        self.xlmMetadata = WalletOptions.XLMMetadata(json: json)
    }
}
