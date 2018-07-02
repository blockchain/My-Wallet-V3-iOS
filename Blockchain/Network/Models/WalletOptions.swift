//
//  WalletOptions.swift
//  Blockchain
//
//  Created by kevinwu on 6/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

private struct Keys {
    static let mobile = "mobile"
    static let walletRoot = "walletRoot"
    static let maintenance = "maintenance"
    static let mobileInfo = "mobileInfo"
}

struct WalletOptions {

    // MARK: - Internal Structs

    struct Mobile {
        let walletRoot: String?
    }

    struct MobileInfo {
        let message: String?
    }

    // MARK: - Properties

    let downForMaintenance: Bool

    let mobileInfo: MobileInfo?

    let mobile: Mobile?
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

extension WalletOptions {
    init(json: JSON) {
        self.downForMaintenance = json[Keys.maintenance] as? Bool ?? false
        self.mobile = WalletOptions.Mobile(json: json)
        self.mobileInfo = WalletOptions.MobileInfo(json: json)
    }
}
