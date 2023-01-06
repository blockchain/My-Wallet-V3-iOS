// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum InfoDictionaryHelper {

    public enum Key: String {
        case apiURL = "API_URL"
        case exchangeURL = "EXCHANGE_URL"
        case explorerServer = "EXPLORER_SERVER"
        case retailCoreURL = "RETAIL_CORE_URL"
        case walletServer = "WALLET_SERVER"
        case certificatePinning = "PIN_CERTIFICATE"
        case everyPayURL = "EVERYPAY_API_URL"
        case swiftyBeaverAppId = "SWIFTY_BEAVER_APP_ID"
        case swiftyBeaverAppSecret = "SWIFTY_BEAVER_APP_SECRET"
        case swiftyBeaverAppKey = "SWIFTY_BEAVER_APP_KEY"
        case websocketURL = "WEBSOCKET_SERVER"
        case recaptchaBypass = "GOOGLE_RECAPTCHA_BYPASS"
    }

    private static let infoDictionary = MainBundleProvider.mainBundle.infoDictionary

    public static func value(for key: Key) -> String! {
        infoDictionary?[key.rawValue] as? String
    }

    public static func valueIfExists(for key: Key, prefix: String? = nil) -> String? {
        let value = infoDictionary?[key.rawValue] as? String
        if let prefix, let value {
            return prefix + value
        }
        return value
    }
}
