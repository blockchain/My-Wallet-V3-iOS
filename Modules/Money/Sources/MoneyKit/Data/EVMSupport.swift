// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ToolKit

protocol EVMSupportAPI: AnyObject {
    func isEnabled(network: String) -> Bool
}

final class EVMSupport: EVMSupportAPI {

    private let app: AppProtocol
    private lazy var supportedEVMNetworksLazy: [String] = app.remoteConfiguration.get(
        blockchain.app.configuration.evm.supported,
        as: [String].self,
        or: []
    )

    init(app: AppProtocol) {
        self.app = app
    }

    func isEnabled(network: String) -> Bool {
        supportedEVMNetworksLazy.contains(network)
    }
}
