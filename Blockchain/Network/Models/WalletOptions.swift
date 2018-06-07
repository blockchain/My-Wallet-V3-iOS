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

    let downForMaintenance: Bool?

    struct Mobile {
        let walletRoot: String?

        init(_ response: [String: Any]) {
            if let mobile = response[Keys.mobile] as? [String: String] {
                walletRoot = mobile[Keys.walletRoot]
            } else {
                walletRoot = nil
            }
        }
    }

    let mobile: Mobile?

    struct MobileInfo {
        let message: String?

        init(_ response: [String: Any]) {
            if let mobileInfo = response[Keys.mobile] as? [String: String] {
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
    init?(response: [String: Any]) {
        downForMaintenance = response[Keys.maintenance] as? Bool
        self.mobile = WalletOptions.Mobile(response)
        self.mobileInfo = WalletOptions.MobileInfo(response)
    }
}
