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
        case appReviewPromptCount = "debug_appReviewPromptCount"
        case enableCertificatePinning = "debug_certificatePinning"
        case securityReminderTimer = "debug_securiterReminderTimer"
        case simulateSurge = "debug_simulateSurge"
        case simulateZeroTicker = "debug_zeroTicker"
        case createWalletPrefill = "debug_createWalletPrefill"
        case useHomebrewForExchange = "debug_useHomebrewForExchange"
    }

    enum Keys: String {
        case appBecameActiveCount = "appBecameActiveCount"
        case assetType = "assetType"
        case didFailBiometrySetup = "didFailBiometrySetup"
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
        case shouldHideBuySellCard = "shouldHideBuySellNotificationCard"
        case shouldShowBiometrySetup = "shouldShowBiometrySetup"
        case swipeToReceiveEnabled = "swipeToReceive"
        case symbolLocal = "symbolLocal"
        case biometryEnabled = "biometryEnabled"
        case hideTransferAllFundsAlert = "hideTransferAllFundsAlert"
        case defaultAccountLabelledAddressesCount = "defaultAccountLabelledAddressesCount"
        case dontAskUserToShowAppReviewPrompt = "dontAskUserToShowAppReviewPrompt"
    }

    func migrateLegacyKeysIfNeeded() {
        migrateBool(fromKey: "didFailTouchIDSetup", toKey: Keys.didFailBiometrySetup.rawValue)
        migrateBool(fromKey: "shouldShowTouchIDSetup", toKey: Keys.shouldShowBiometrySetup.rawValue)
        migrateBool(fromKey: "touchIDEnabled", toKey: Keys.biometryEnabled.rawValue)
    }

    private func migrateBool(fromKey: String, toKey: String) {
        guard let value = self.object(forKey: fromKey) as? Bool else { return }
        self.set(value, forKey: toKey)
        self.removeObject(forKey: fromKey)
    }
}
