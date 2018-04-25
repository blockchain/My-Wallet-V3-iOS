//
//  UserDefaults.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
// Please keep the keys sorted alphabetically (:

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
        case encryptedPinPassword = "encryptedPINPassword"
        case environment = "environment"
        case firstRun = "firstRun"
        case hasSeenUpgradeToHdScreen = "hasSeenUpgradeToHdScreen"
        case swipeToReceiveEnabled = "swipeToReceive"
        case symbolLocal = "symbolLocal"
        case pinKey = "pinKey"
    }
}
