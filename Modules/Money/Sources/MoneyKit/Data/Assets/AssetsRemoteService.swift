// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

final class AssetsRemoteService: AssetsRemoteServiceAPI {

    private let client: AssetsClientAPI
    private let filePathProvider: FilePathProviderAPI
    private let fileIO: FileIOAPI
    private let jsonDecoder: JSONEncoder

    init(
        client: AssetsClientAPI,
        filePathProvider: FilePathProviderAPI,
        fileIO: FileIOAPI,
        jsonDecoder: JSONEncoder
    ) {
        self.client = client
        self.filePathProvider = filePathProvider
        self.fileIO = fileIO
        self.jsonDecoder = jsonDecoder
    }

    var refreshCache: AnyPublisher<Void, Never> {
        [
            refreshCoinAssetsCache,
            refreshCustodialAssetsCache,
            refreshEthereumERC20AssetsCache,
            refreshOtherERC20AssetsCache,
            refreshNetworkConfigCache
        ]
        .zip()
        .mapToVoid()
    }

    private var refreshCoinAssetsCache: AnyPublisher<Void, Never> {
        client.coinAssets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.url(fileName: .remoteCoin)!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    private var refreshCustodialAssetsCache: AnyPublisher<Void, Never> {
        client.custodialAssets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.url(fileName: .remoteCustodial)!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    private var refreshEthereumERC20AssetsCache: AnyPublisher<Void, Never> {
        client.ethereumERC20Assets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.url(fileName: .remoteEthereumERC20)!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    private var refreshOtherERC20AssetsCache: AnyPublisher<Void, Never> {
        client.otherERC20Assets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.url(fileName: .remoteOtherERC20)!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    private var refreshNetworkConfigCache: AnyPublisher<Void, Never> {
        client.networkConfig
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.url(fileName: .remoteNetworkConfig)!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}
