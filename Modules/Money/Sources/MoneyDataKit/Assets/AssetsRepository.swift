// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyDomainKit
import ToolKit

protocol AssetsRepositoryAPI {
    var coinAssets: [AssetModel] { get }
    var custodialAssets: [AssetModel] { get }
    var ethereumERC20Assets: [AssetModel] { get }
    var otherERC20Assets: [AssetModel] { get }
    var enabledEVMs: [EVMNetworkConfig] { get }
}

struct AssetsRepository: AssetsRepositoryAPI {

    var coinAssets: [AssetModel] {
        supportedAssets(fileName: .remoteCoin, fallBack: .localCoin)
            .filter(\.kind.isCoin)
    }

    var custodialAssets: [AssetModel] {
        supportedAssets(fileName: .remoteCustodial, fallBack: .localCustodial)
            .filter(\.products.enablesCurrency)
    }

    var ethereumERC20Assets: [AssetModel] {
        supportedAssets(fileName: .remoteEthereumERC20, fallBack: .localEthereumERC20)
            .filter(\.kind.isERC20)
            .filter { $0.kind.erc20ParentChain == "ETH" }
    }

    var otherERC20Assets: [AssetModel] {
        supportedAssets(fileName: .remoteOtherERC20, fallBack: .localOtherERC20)
            .filter(\.kind.isERC20)
            .filter { $0.kind.erc20ParentChain != "ETH" }
    }

    var enabledEVMs: [EVMNetworkConfig] {
        let response: NetworkConfigResponse
        do {
            try response = fileLoader.load(
                fileName: .remoteNetworkConfig,
                fallBack: .localNetworkConfig,
                as: NetworkConfigResponse.self
            ).get()
        } catch {
            return []
        }
        return response
            .networks
            .filter { $0.type == .evm }
            .compactMap(EVMNetworkConfig.init(response:))
    }

    private func supportedAssets(fileName: FileName, fallBack fallBackFileName: FileName) -> [AssetModel] {
        let response: AssetsResponse
        do {
            try response = fileLoader.load(
                fileName: fileName,
                fallBack: fallBackFileName,
                as: AssetsResponse.self
            ).get()
        } catch {
            if BuildFlag.isInternal {
                fatalError("Can' load local custodial assets. \(error.localizedDescription)")
            }
            return []
        }
        return response.currencies
            .enumerated()
            .compactMap { index, item -> AssetModel? in
                AssetModel(assetResponse: item, sortIndex: index, sanitizeEVMAssets: evmSupport.sanitizeTokenNamesEnabled)
            }
    }

    private let fileLoader: FileLoaderAPI
    private let evmSupport: EVMSupportAPI

    init(
        fileLoader: FileLoaderAPI,
        evmSupport: EVMSupportAPI
    ) {
        self.fileLoader = fileLoader
        self.evmSupport = evmSupport
    }
}

extension EVMNetworkConfig {
    init?(response: NetworkConfigResponse.Network) {
        guard response.type == .evm else {
            return nil
        }
        guard case .dictionary(let identifiers) = response.identifiers else {
            return nil
        }
        guard case .number(let chainID) = identifiers["chainId"] else {
            return nil
        }
        guard let nodeURL = response.nodeUrls.first else {
            return nil
        }
        self.init(
            name: response.name,
            chainID: BigUInt(chainID),
            nativeAsset: response.nativeAsset,
            explorerUrl: response.explorerUrl,
            networkTicker: response.networkTicker,
            nodeURL: nodeURL,
            shortName: response.shortName
        )
    }
}
