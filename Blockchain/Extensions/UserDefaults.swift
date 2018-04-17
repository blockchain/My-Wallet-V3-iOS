//
//  UserDefaults.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
extension UserDefaults {
    enum DebugKeys: String {
        case appReviewPromptTimer = "appReviewPromptTimer"
        case enableCertificatePinning = "certificatePinning"
        case securityReminderTimer = "securiterReminderTimer"
        case simulateSurge = "simulateSurge"
        case simulateZeroTicker = "zeroTicker"
    }

    enum Keys: String {
        case assetType = "assetType"
        case environment = "environment"
        case swipeToReceiveEnabled = "swipeToReceive"
        case pinKey = "pinKey"
        case encryptedPinPassword = "encryptedPINPassword"
    }
}
