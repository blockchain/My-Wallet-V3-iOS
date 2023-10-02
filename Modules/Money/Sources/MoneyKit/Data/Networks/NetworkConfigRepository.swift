// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation

public protocol NetworkConfigRepositoryAPI {
    var evmConfigs: [EVMNetworkConfig] { get }
    var dscConfigs: [DSCNetworkConfig] { get }
}

final class NetworkConfigRepository: NetworkConfigRepositoryAPI {

    static let `default`: NetworkConfigRepositoryAPI = {
        let app: AppProtocol = runningApp
        let assetsRepository: AssetsRepositoryAPI = AssetsRepository.default
        return NetworkConfigRepository(
            app: app,
            repository: assetsRepository
        )
    }()

    private let app: AppProtocol
    private let repository: AssetsRepositoryAPI

    // EVM

    private let evmConfigsLock = NSLock()
    private lazy var evmConfigsLazy: [EVMNetworkConfig] = [EVMNetworkConfig.ethereum] + evmConfigsExternal
    private lazy var evmSupport: [String] = app.remoteConfiguration.get(
        blockchain.app.configuration.evm.supported,
        as: [String].self,
        or: []
    )
    private var evmConfigsExternal: [EVMNetworkConfig] {
        repository.enabledEVMs
            .filter { $0.networkTicker != "ETH" }
            .filter { evmSupport.contains($0.networkTicker) }
    }

    // DSC

    private let dscConfigsLock = NSLock()
    private lazy var dscConfigsLazy: [DSCNetworkConfig] = repository.enabledDSCNetworks
        .filter { dscSupport.contains($0.networkTicker) }
    private lazy var dscSupport: [String] = app.remoteConfiguration.get(
        blockchain.app.configuration.dynamicselfcustody.networks,
        as: [String].self,
        or: []
    )

    init(
        app: AppProtocol,
        repository: AssetsRepositoryAPI
    ) {
        self.app = app
        self.repository = repository
    }

    var evmConfigs: [EVMNetworkConfig] {
        defer { evmConfigsLock.unlock() }
        evmConfigsLock.lock()
        return evmConfigsLazy
    }

    var dscConfigs: [DSCNetworkConfig] {
        defer { dscConfigsLock.unlock() }
        dscConfigsLock.lock()
        return dscConfigsLazy
    }
}
