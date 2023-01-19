// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

/// A `NetworkCredentialProvider` allows access to credential values stored outside this module.
protocol NetworkCredentialProviderAPI {
    var apiURL: String { get }
    var exchangeURL: String { get }
    var explorerServer: String { get }
    var retailCoreURL: String { get }
    var walletServer: String { get }
    var certificatePinning: String { get }
    var everyPayURL: String { get }
    var swiftyBeaverAppId: String { get }
    var swiftyBeaverAppSecret: String { get }
    var swiftyBeaverAppKey: String { get }
    var websocketConversionUrl: String { get }
}

/// This implementation of a `NetworkCredentialProviderAPI`will fetch the
/// credential values from the main Bundle info dictionary.
final class NetworkCredentialProvider: NetworkCredentialProviderAPI {

    var apiURL: String {
        InfoDictionaryHelper.value(for: .apiURL)
    }

    var exchangeURL: String {
        InfoDictionaryHelper.value(for: .exchangeURL)
    }

    var explorerServer: String {
        InfoDictionaryHelper.value(for: .explorerServer)
    }

    var retailCoreURL: String {
        InfoDictionaryHelper.value(for: .retailCoreURL)
    }

    var walletServer: String {
        InfoDictionaryHelper.value(for: .walletServer)
    }

    var certificatePinning: String {
        InfoDictionaryHelper.value(for: .certificatePinning)
    }

    var everyPayURL: String {
        InfoDictionaryHelper.value(for: .everyPayURL)
    }

    var swiftyBeaverAppId: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppId)
    }

    var swiftyBeaverAppSecret: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppSecret)
    }

    var swiftyBeaverAppKey: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppKey)
    }

    var websocketConversionUrl: String {
        InfoDictionaryHelper.value(for: .websocketURL)
    }
}
