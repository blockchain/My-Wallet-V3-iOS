// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// This model contains wallet-specific settings (e.g. the user's preferred language,
/// currency symbol, 2-factor authentication type, etc.)
struct SettingsResponse {

    // MARK: Types

    /// List of known feature flags.
    enum Feature: String {
        case segwit
    }

    // MARK: Properties

    let language: String
    let currency: String
    let email: String
    let guid: String
    let emailNotificationsEnabled: Bool
    let smsNumber: String?
    let smsVerified: Bool
    let emailVerified: Bool
    let authenticator: Int
    let countryCode: String
    let invited: [Feature: Bool]
    let recommendImportedSweep: Bool
}

extension SettingsResponse: Decodable {

    // MARK: Types

    enum CodingKeys: String, CodingKey {
        case language
        case currency
        case email
        case guid
        case smsNumber = "sms_number"
        case smsVerified = "sms_verified"
        case emailVerified = "email_verified"
        case authenticator = "auth_type"
        case countryCode = "country_code"
        case notifications = "notifications_type"
        case recommendImportedSweep = "recommend_imported_sweep"
        case invited
    }

    // MARK: Init

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.language = try values.decode(String.self, forKey: .language)
        self.currency = try values.decode(String.self, forKey: .currency)
        self.email = try values.decode(String.self, forKey: .email)
        self.guid = try values.decode(String.self, forKey: .guid)
        self.smsNumber = try? values.decodeIfPresent(String.self, forKey: .smsNumber)
        self.smsVerified = try values.decode(Int.self, forKey: .smsVerified) == 1
        self.emailVerified = try values.decode(Int.self, forKey: .emailVerified) == 1
        self.authenticator = try values.decode(Int.self, forKey: .authenticator)
        self.countryCode = try values.decode(String.self, forKey: .countryCode)
        let notifications = try values.decode([Int].self, forKey: .notifications)
        self.emailNotificationsEnabled = notifications.contains(1)
        self.recommendImportedSweep = try values.decodeIfPresent(Bool.self, forKey: .recommendImportedSweep) ?? false
        self.invited = try values
            .decode([String: Bool].self, forKey: .invited)
            .reduce(into: [Feature: Bool]()) { result, this in
                guard let feature = Feature(rawValue: this.key) else {
                    return
                }
                result[feature] = this.value
            }
    }
}
