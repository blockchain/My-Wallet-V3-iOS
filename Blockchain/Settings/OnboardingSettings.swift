//
//  OnboardingSettings.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Encapsulates all onboarding-related settings for the user
@objc class OnboardingSettings: NSObject {
    static let shared: OnboardingSettings = OnboardingSettings()

    @objc class func sharedInstance() -> OnboardingSettings { return shared }

    private lazy var defaults: UserDefaults = {
        return UserDefaults.standard
    }()

    /// Property indicating if setting up biometric authentication failed
    var didFailBiometrySetup: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.Keys.didFailBiometrySetup.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.didFailBiometrySetup.rawValue)
        }
    }

    /// Property indicating if the user saw the HD wallet upgrade screen
    var hasSeenUpgradeToHdScreen: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.Keys.hasSeenUpgradeToHdScreen.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.hasSeenUpgradeToHdScreen.rawValue)
        }
    }

    /// Property indicating if the biometric authentication set-up should be shown to the user
    var shouldShowBiometrySetup: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.Keys.shouldShowBiometrySetup.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.shouldShowBiometrySetup.rawValue)
        }
    }

    /// Property indicating if this is the first time the user is running the application
    var firstRun: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.Keys.firstRun.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.firstRun.rawValue)
        }
    }

    /// Property indicating if the buy/sell onboarding card should be shown
    @objc var shouldHideBuySellCard: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.Keys.shouldHideBuySellCard.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.shouldHideBuySellCard.rawValue)
        }
    }

    /// Property indicating if the user has seen all onboarding cards
    @objc var hasSeenAllCards: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.Keys.hasSeenAllCards.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.hasSeenAllCards.rawValue)
        }
    }

    private override init() {
        super.init()
    }

}
