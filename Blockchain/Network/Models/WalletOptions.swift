//
//  WalletOptions.swift
//  Blockchain
//
//  Created by kevinwu on 6/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct WalletOptions {
    private struct Keys {
        static let mobile = "mobile"
        static let walletRoot = "walletRoot"
        static let maintenance = "maintenance"
        static let mobileInfo = "mobileInfo"
    }

    let downForMaintenance: Bool

    struct Mobile {
        let walletRoot: String?

        init(json: JSON) {
            if let mobile = json[Keys.mobile] as? [String: String] {
                walletRoot = mobile[Keys.walletRoot]
            } else {
                walletRoot = nil
            }
        }
    }

    let mobile: Mobile?

    struct MobileInfo {
        let message: String?

        init(json: JSON) {
            if let mobileInfo = json[Keys.mobile] as? [String: String] {
                if let code = Locale.current.languageCode {
                    message = mobileInfo[code] ?? mobileInfo["en"]
                } else {
                    message = mobileInfo["en"]
                }
            } else {
                message = nil
            }
        }
    }

    let mobileInfo: MobileInfo?
}

extension WalletOptions {
    init(json: JSON) {
        downForMaintenance = json[Keys.maintenance] as? Bool ?? false
        self.mobile = WalletOptions.Mobile(json: json)
        self.mobileInfo = WalletOptions.MobileInfo(json: json)
    }
}
