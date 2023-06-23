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
        case websocketURL = "WEBSOCKET_SERVER"
        case recaptchaBypass = "GOOGLE_RECAPTCHA_BYPASS"
        case iterableApiKey = "ITERABLE_API_KEY"
        case walletConnectId = "WALLET_CONNECT_PRODUCT_ID"
    }

    private static let infoDictionary = MainBundleProvider.mainBundle.infoDictionary

    public static func value(for key: Key) -> String! {
        infoDictionary?[key.rawValue] as? String
    }

    public static func valueIfExists(for key: Key, prefix: String? = nil) -> String? {
        guard let value = infoDictionary?[key.rawValue] as? String, value.isNotEmpty else {
            return nil
        }
        if let prefix {
            return prefix + value
        }
        return value
    }
}
