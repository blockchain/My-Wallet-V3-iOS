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
        case didFailTouchIDSetup = "didFailTouchIDSetup"
        case encryptedPinPassword = "encryptedPINPassword"
        case environment = "environment"
        case firstRun = "firstRun"
        case hasEndedFirstSession = "hasEndedFirstSession"
        case hasSeenAllCards = "hasSeenAllCards"
        case hasSeenEmailReminder = "hasSeenEmailReminder"
        case hasSeenUpgradeToHdScreen = "hasSeenUpgradeToHdScreen"
        case password = "password"
        case passwordPartHash = "passwordPartHash"
        case pin = "pin"
        case pinKey = "pinKey"
        case reminderModalDate = "reminderModalDate"
        case shouldHideAllCards = "shouldHideAllCards"
        case shouldHideBuySellCard = "shouldHideBuySellNotificationCard"
        case shouldShowTouchIDSetup = "shouldShowTouchIDSetup"
        case swipeToReceiveEnabled = "swipeToReceive"
        case symbolLocal = "symbolLocal"
        case touchIDEnabled = "touchIDEnabled"
        case hideTransferAllFundsAlert = "hideTransferAllFundsAlert"
        case defaultAccountLabelledAddressesCount = "defaultAccountLabelledAddressesCount"
    }
}
