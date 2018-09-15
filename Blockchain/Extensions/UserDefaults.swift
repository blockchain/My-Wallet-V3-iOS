//
//  UserDefaults.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
// Please keep the keys sorted alphabetically (:

import Foundation

extension UserDefaults {

    // TICKET: IOS-1289 - Refactor key-value mapping such that key = value
    // Refactor enableCertificatePinning, simulateZeroTicker, shouldHideBuySellCard,
    // swipeToReceiveEnabled such that key = value
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
        case appBecameActiveCount
        case assetType
        case biometryEnabled
        case defaultAccountLabelledAddressesCount
        case didFailBiometrySetup
        case dontAskUserToShowAppReviewPrompt
        case encryptedPinPassword
        case environment
        case firstRun
        case graphTimeFrameKey = "timeFrame"
        case hasEndedFirstSession
        case hasSeenAllCards
        case hasSeenEmailReminder
        case hasSeenUpgradeToHdScreen
        case hideTransferAllFundsAlert
        case password
        case passwordPartHash
        case pin
        case pinKey
        case reminderModalDate
        case shouldHideBuySellCard = "shouldHideBuySellNotificationCard"
        case shouldShowBiometrySetup
        case shouldShowKYCAnnouncementCard
        case swipeToReceiveEnabled = "swipeToReceive"
        case symbolLocal
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
