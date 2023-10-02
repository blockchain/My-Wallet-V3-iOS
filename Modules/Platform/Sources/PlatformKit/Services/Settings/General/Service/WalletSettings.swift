// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import WalletPayloadKit

public struct WalletSettings: Equatable {

    public enum Feature: String {
        case segwit
    }

    private let rawDisplayCurrency: String

    public let countryCode: String
    public let language: String
    public let email: String
    public let smsNumber: String?
    public let isSMSVerified: Bool
    public let isEmailNotificationsEnabled: Bool
    public let isEmailVerified: Bool
    public let authenticator: WalletAuthenticatorType
    public let features: [Feature: Bool]
    public let recommendImportedSweep: Bool

    public var displayCurrency: FiatCurrency? {
        FiatCurrency(rawValue: rawDisplayCurrency)
    }

    init(response: SettingsResponse) {
        self.rawDisplayCurrency = response.currency
        self.countryCode = response.countryCode
        self.language = response.language
        self.email = response.email
        self.smsNumber = response.smsNumber
        self.isSMSVerified = response.smsVerified
        self.isEmailVerified = response.emailVerified
        self.isEmailNotificationsEnabled = response.emailNotificationsEnabled
        self.authenticator = WalletAuthenticatorType(rawValue: response.authenticator) ?? .standard
        self.features = response.invited.reduce(into: [Feature: Bool]()) { result, data in
            guard let key = Feature(rawValue: data.key.rawValue) else {
                return
            }
            result[key] = data.value
        }
        self.recommendImportedSweep = response.recommendImportedSweep
    }
}
