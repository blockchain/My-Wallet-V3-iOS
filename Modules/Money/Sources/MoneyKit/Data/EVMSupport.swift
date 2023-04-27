// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ToolKit

protocol EVMSupportAPI: AnyObject {

    var sanitizeTokenNamesEnabled: Bool { get }

    func isEnabled(network: String) -> Bool
}

final class EVMSupport: EVMSupportAPI {
    func isEnabled(network: String) -> Bool {
        supportedEVMNetworksLazy.contains(network)
    }

    var sanitizeTokenNamesEnabled: Bool {
        defer { sanitizeTokenNamesEnabledLock.unlock() }
        sanitizeTokenNamesEnabledLock.lock()
        return sanitizeTokenNamesEnabledLazy
    }

    private lazy var supportedEVMNetworksLazy: [String] = (
        try? app.remoteConfiguration.get(blockchain.app.configuration.evm.supported, as: [String].self)
    ) ?? []

    private lazy var sanitizeTokenNamesEnabledLazy: Bool = fetchBool(
        tag: blockchain.app.configuration.evm.name.sanitize.is.enabled
    )

    private let sanitizeTokenNamesEnabledLock = NSLock()
    private let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

    private func fetchBool(tag: Tag.Event) -> Bool {
        guard let value = try? app.remoteConfiguration.get(tag) else {
            return false
        }
        guard let isEnabled = value as? Bool else {
            return false
        }
        return isEnabled
    }
}
