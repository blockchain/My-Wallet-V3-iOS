//  Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit

public protocol BlockchainNameResolutionServiceAPI {

    func validate(
        domainName: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<ReceiveAddress?, Never>

    func reverseResolve(
        address: String,
        currency: String
    ) -> AnyPublisher<[String], Never>
}

extension BlockchainNameResolutionServiceAPI {

    public func reverseResolve(
        address: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<[String], Never> {
        reverseResolve(address: address, currency: currency.code)
    }

    public func reverseResolve(
        address: String,
        currencyType: CurrencyType
    ) -> AnyPublisher<[String], Never> {
        guard let cryptoCurrency = currencyType.cryptoCurrency else {
            return .just([])
        }
        return reverseResolve(address: address, currency: cryptoCurrency)
    }
}

final class BlockchainNameResolutionService: BlockchainNameResolutionServiceAPI {

    private let repository: BlockchainNameResolutionRepositoryAPI
    private let factory: ExternalAssetAddressServiceAPI

    init(
        repository: BlockchainNameResolutionRepositoryAPI = resolve(),
        factory: ExternalAssetAddressServiceAPI = resolve()
    ) {
        self.repository = repository
        self.factory = factory
    }

    func validate(
        domainName: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<ReceiveAddress?, Never> {
        guard preValidate(domainName: domainName) else {
            return .just(nil)
        }
        return repository
            .resolve(
                domainName: domainName,
                currency: currency.code
            )
            .eraseError()
            .flatMap { [factory] response -> AnyPublisher<ReceiveAddress?, Error> in
                factory
                    .makeExternalAssetAddress(
                        asset: currency,
                        address: response.address,
                        label: Self.label(address: response.address, domain: domainName),
                        onTxCompleted: { _ in AnyPublisher.just(()) }
                    )
                    .map { $0 as ReceiveAddress }
                    .publisher
                    .eraseToAnyPublisher()
                    .eraseError()
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func reverseResolve(
        address: String,
        currency: String
    ) -> AnyPublisher<[String], Never> {
        repository
            .reverseResolve(
                address: address,
                currency: currency
            )
            .replaceError(with: [])
            .map { $0.map(\.domainName) }
            .eraseToAnyPublisher()
    }

    private static func label(address: String, domain: String) -> String {
        "\(domain) (\(address.prefix(4))...\(address.suffix(4)))"
    }

    private func preValidate(domainName: String) -> Bool {
        preValidateEmojiDomain(domainName)
            || preValidateRegularDomain(domainName)
    }

    private func preValidateEmojiDomain(_ domainName: String) -> Bool {
        domainName.containsEmoji
    }

    private func preValidateRegularDomain(_ domainName: String) -> Bool {
        // Separated by '.' (period)
        let components = domainName.components(separatedBy: ".")
        // Must have more than one component
        guard components.count > 1 else {
            return false
        }
        // No component may be empty
        guard !components.contains(where: \.isEmpty) else {
            return false
        }
        // Pre validation passes
        return true
    }
}
