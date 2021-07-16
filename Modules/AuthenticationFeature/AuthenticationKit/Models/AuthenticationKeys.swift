// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class AuthenticationKeys: NSObject {

    public static var googleRecaptchaSiteKey: String {
        InfoDictionaryHelper.value(for: .googleRecaptchaSiteKey)
    }
}

private struct InfoDictionaryHelper {
    enum Key: String {
        case googleRecaptchaSiteKey = "GOOGLE_RECAPTCHA_SITE_KEY"
    }

    private static let infoDictionary = Bundle(for: AuthenticationKeys.self).infoDictionary

    static func value(for key: Key) -> String! {
        infoDictionary?[key.rawValue] as? String
    }

    static func value(for key: Key, prefix: String) -> String! {
        guard let value = value(for: key) else {
            return nil
        }
        return prefix + value
    }
}