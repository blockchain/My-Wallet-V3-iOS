//
//  DebugSettings.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
class DebugSettings: NSObject {
    static let shared = DebugSettings()

    @objc class func sharedInstance() -> DebugSettings {
        return shared
    }

    @objc var createWalletPrefill: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.DebugKeys.createWalletPrefill.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.createWalletPrefill.rawValue)
        }
    }

    @objc var useHomebrewForExchange: Bool {
        get {
            return defaults.bool(forKey: UserDefaults.DebugKeys.useHomebrewForExchange.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.useHomebrewForExchange.rawValue)
        }
    }

    private lazy var defaults: UserDefaults = {
        return UserDefaults.standard
    }()

    private override init() {
    }
}
