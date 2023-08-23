// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

protocol AssetsRepositoryAPI {
    var coinAssets: [AssetModel] { get }
    var custodialAssets: [AssetModel] { get }
    var ethereumERC20Assets: [AssetModel] { get }
    var otherERC20Assets: [AssetModel] { get }
    var enabledEVMs: [EVMNetworkConfig] { get }
    var enabledDSCNetworks: [DSCNetworkConfig] { get }
}

struct AssetsRepository: AssetsRepositoryAPI {

    static var `default`: Self {
        let fileLoader: FileLoaderAPI = FileLoader(
            filePathProvider: FilePathProvider(
                fileManager: .default
            ),
            jsonDecoder: .init()
        )
        return AssetsRepository(
            fileLoader: fileLoader
        )
    }

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
        return EVMNetworkConfig.from(response: response)
    }

    var enabledDSCNetworks: [DSCNetworkConfig] {
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
        return DSCNetworkConfig.from(response: response)
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
                AssetModel(assetResponse: item, sortIndex: index)
            }
    }

    private let fileLoader: FileLoaderAPI

    init(fileLoader: FileLoaderAPI) {
        self.fileLoader = fileLoader
    }
}
