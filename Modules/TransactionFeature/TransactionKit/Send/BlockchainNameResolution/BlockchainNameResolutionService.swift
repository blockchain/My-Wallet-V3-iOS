//
//  BlockchainNameResolutionService.swift
//  ActivityKit
//
//  Created by Paulo on 27/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import PlatformKit

public protocol BlockchainNameResolutionServicing {
    func validate(domainName: String, currency: CryptoCurrency) -> AnyPublisher<ReceiveAddress?, Never>
}

final class BlockchainNameResolutionService: BlockchainNameResolutionServicing {

    private let client: BlockchainNameResolutionAPI
    private let factory: CryptoReceiveAddressFactoryService

    init(client: BlockchainNameResolutionAPI = resolve(),
         factory: CryptoReceiveAddressFactoryService = resolve()) {
        self.client = client
        self.factory = factory
    }

    func validate(domainName: String, currency: CryptoCurrency) -> AnyPublisher<ReceiveAddress?, Never> {
        guard preValidate(domainName: domainName) else {
            return .just(nil)
        }
        return client
            .resolve(domainName: domainName, currency: currency.code.lowercased())
            .eraseError()
            .flatMap { [factory] response -> AnyPublisher<ReceiveAddress?, Error> in
                factory
                    .makeExternalAssetAddress(
                        asset: currency,
                        address: response.address,
                        label: domainName,
                        onTxCompleted: { _ in .empty() }
                    )
                    .map { $0 as ReceiveAddress }
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private func preValidate(domainName: String) -> Bool {
        let components = domainName.components(separatedBy: ".")
        guard components.count == 2 else {
            return false
        }
        guard !components[0].isEmpty else {
            return false
        }
        guard !components[1].isEmpty else {
            return false
        }
        return true
    }
}
