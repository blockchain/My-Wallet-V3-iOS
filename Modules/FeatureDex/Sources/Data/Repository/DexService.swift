// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import Dependencies
import DIKit
import Errors
import FeatureDexDomain
import Foundation
import MoneyKit
import NetworkKit

public struct DexService {
    @Dependency(\.dexAllowanceRepository) var dexAllowanceRepository

    public func allowance(
        app: AppProtocol,
        currency: CryptoCurrency
    ) -> AnyPublisher<Result<DexAllowanceResult, UX.Error>, Never> {
        receiveAddressProvider(app, currency)
            .optional()
            .replaceError(with: nil)
            .flatMap { address -> AnyPublisher<Result<DexAllowanceResult, UX.Error>, Never> in
                guard let address else {
                    return .just(.failure(UX.Error(error: nil)))
                }
                return allowance(address: address, currency: currency)
            }
            .eraseToAnyPublisher()
    }

    func allowance(
        address: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<Result<DexAllowanceResult, UX.Error>, Never> {
        guard !currency.isCoin else {
            return .just(.success(.ok))
        }
        return dexAllowanceRepository
            .fetch(address: address, currency: currency)
            .map { output -> DexAllowanceResult in
                output.isOK ? .ok : .nok
            }
            .mapError(UX.Error.init(error:))
            .result()
            .eraseToAnyPublisher()
    }

    public var balances: () -> AnyPublisher<Result<[DexBalance], UX.Error>, Never>
    public var quote: (DexQuoteInput) -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never>
    public var receiveAddressProvider: (AppProtocol, CryptoCurrency) -> AnyPublisher<String, Error>
}

struct DexServiceDependencyKey: DependencyKey {
    static var liveValue: DexService = DexService(
        balances: {
            let service: DelegatedCustodyBalanceRepositoryAPI = DIKit.resolve()
            return service
                .balances
                .map { balances in
                    dexBalances(balances)
                }
                .mapError(UX.Error.init(error:))
                .result()
                .eraseToAnyPublisher()
        },
        quote: { quoteInput in
            let service = DexQuoteRepository(
                client: Client(
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                ),
                currenciesService: DIKit.resolve()
            )
            return service.quote(input: quoteInput)
        },
        receiveAddressProvider: { app, cryptoCurrency in
            receiveAddress(
                app: app,
                cryptoCurrency: cryptoCurrency
            )
        }
    )

    static var previewValue: DexService = DexService(
        balances: { .just(.success(dexBalances(.preview))) },
        quote: { _ in .just(.failure(.init(title: "DexService", message: "Hi"))) },
        receiveAddressProvider: { _, _ in .just("0x00000000000000000000000000000000DEADBEEF") }
    )

    static var testValue: DexService { previewValue }
}

extension DependencyValues {
    public var dexService: DexService {
        get { self[DexServiceDependencyKey.self] }
        set { self[DexServiceDependencyKey.self] = newValue }
    }
}

private func dexBalances(
    _ balances: DelegatedCustodyBalances
) -> [DexBalance] {
    balances.balances
        .filter(\.balance.isPositive)
        .compactMap(\.balance.cryptoValue)
        .filter(\.currency.isSupportedByDex)
        .map(DexBalance.init)
}

extension CryptoCurrency {
    var isSupportedByDex: Bool {
        self == .ethereum || assetModel.kind.erc20ParentChain == "ETH"
    }
}

private func receiveAddress(
    app: AppProtocol,
    cryptoCurrency: CryptoCurrency
) -> AnyPublisher<String, Error> {
    accountId(app: app, cryptoCurrency: cryptoCurrency)
        .flatMap { [app] identifier in
            address(app: app, accoundId: identifier)
        }
        .eraseToAnyPublisher()
}

private func accountId(
    app: AppProtocol,
    cryptoCurrency: CryptoCurrency
) -> AnyPublisher<String, Error> {
    app
        .publisher(
            for: blockchain.coin.core.accounts.DeFi.asset[cryptoCurrency.code],
            as: [String].self
        )
        .first()
        .map { result -> String? in
            let value = result.value
            return value?.first
        }
        .setFailureType(to: Error.self)
        .onNil(QuoteError.noReceiveAddress)
        .eraseToAnyPublisher()
}

private func address(
    app: AppProtocol,
    accoundId: String
) -> AnyPublisher<String, Error> {
    app
        .publisher(
            for: blockchain.coin.core.account[accoundId].receive.address,
            as: L_blockchain_coin_core_account_receive.JSON.self
        )
        .first()
        .map { result -> String? in
            let value = result.value
            return value?.address
        }
        .setFailureType(to: Error.self)
        .onNil(QuoteError.noReceiveAddress)
        .eraseToAnyPublisher()
}
