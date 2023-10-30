// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Errors
import Extensions
import FeatureDexDomain
import Foundation
import MoneyKit

final class DexQuoteRepository: DexQuoteRepositoryAPI {

    let currenciesService: EnabledCurrenciesServiceAPI
    let client: QuoteClientAPI
    let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        client: QuoteClientAPI,
        currenciesService: EnabledCurrenciesServiceAPI,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.client = client
        self.currenciesService = currenciesService
        self.scheduler = scheduler
    }

    func quote(
        input: DexQuoteInput
    ) -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never> {
        guard let request = dexQuoteRequest(input: input, currenciesService: currenciesService) else {
            let uxError = UX.Error(error: QuoteError.notReady)
            return .just(.failure(uxError))
        }
        return quote(product: .dex, request: request)
    }

    private func quote(
        product: DexQuoteProduct,
        request: DexQuoteRequest
    ) -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never> {
        let subject = PassthroughSubject<Result<DexQuoteOutput, UX.Error>, Never>()
        let task = Task {
            do {
                let backoff = ExponentialBackoff()
                repeat {
                    try Task.checkCancellation()
                    var response: DexQuoteResponse
                    do {
                        response = try await client
                            .quote(product: product, quote: request)
                            .mapError(Nabu.Error.from(_:))
                            .await()
                    } catch let error as Nabu.Error {
                        guard error.ux.isNil else {
                            // We got a scalable error, stop retrying.
                            throw error
                        }
                        guard await backoff.count() < 4 else {
                            throw error
                        }
                        try await backoff.next()
                        continue
                    } catch let error as AsyncSequenceNextError {
                        throw error
                    } catch {
                        assertionFailure("Unknown error: '\(type(of: error))' '\(error)'")
                        throw error
                    }

                    let expiresAt = expiration(response)
                    let output = DexQuoteOutput(
                        request: request,
                        response: response,
                        currenciesService: currenciesService
                    )

                    try Task.checkCancellation()

                    guard let output else {
                        throw QuoteError.notSupported
                    }

                    subject.send(.success(output))

                    if expiresAt > .now() {
                        try await scheduler.sleep(until: .init(expiresAt))
                        try Task.checkCancellation()
                        await backoff.reset()
                    } else {
                        try await backoff.next()
                    }
                } while Task.isCancelled.isNo
            } catch is CancellationError {
                // Ignore CancellationError
            } catch {
                switch error {
                case let error as UX.Error:
                    subject.send(.failure(error))
                case let error as Nabu.Error:
                    subject.send(.failure(UX.Error(nabu: error)))
                default:
                    subject.send(.failure(UX.Error(error: error)))
                }
            }
            subject.send(completion: .finished)
        }
        return subject
            .handleEvents(receiveCancel: task.cancel)
            .eraseToAnyPublisher()
    }
}

private func expiration(_ value: DexQuoteResponse) -> DispatchTime {
    DispatchTime.now() + TimeInterval.miliseconds(value.quoteTtl)
}

private func dexQuoteRequest(
    input: DexQuoteInput,
    currenciesService: EnabledCurrenciesServiceAPI
) -> DexQuoteRequest? {
    guard let fromCurrency = currencyParams(input.amount.source, input.source, currenciesService) else {
        return nil
    }
    guard let toCurrency = currencyParams(input.amount.destination, input.destination, currenciesService) else {
        return nil
    }
    let params = DexQuoteRequest.Params(
        slippage: "\(input.slippage)",
        skipValidation: input.skipValidation,
        enableBoost: input.expressMode,
        receiveGasOnDestination: input.gasOnDestination
    )
    return DexQuoteRequest(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        takerAddress: input.takerAddress,
        params: params
    )
}

private func currencyParams(
    _ amount: CryptoValue?,
    _ cryptoCurrency: CryptoCurrency,
    _ currenciesService: EnabledCurrenciesServiceAPI
) -> DexQuoteRequest.CurrencyParams? {
    if let amount, !amount.isPositive {
        return nil
    }
    let address = cryptoCurrency.assetModel.kind.erc20ContractAddress
    guard let network = cryptoCurrency.network(currenciesService: currenciesService) else {
        return nil
    }
    return DexQuoteRequest.CurrencyParams(
        chainId: Int(network.networkConfig.chainID),
        symbol: cryptoCurrency.code,
        address: address ?? Constants.nativeAssetAddress,
        amount: amount?.minorString
    )
}
