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
                    } catch {
                        guard await backoff.count() < 4 else { throw error }
                        try await backoff.next()
                        continue
                    }

                    let output = DexQuoteOutput(
                        request: request,
                        response: response,
                        currenciesService: currenciesService
                    )

                    let expiresAt = Date(timeIntervalSinceNow: response.quoteTtl / Double(1000))

                    try Task.checkCancellation()
                    if let output {
                        subject.send(.success(output))
                    } else {
                        subject.send(.failure(UX.Error(error: QuoteError.notSupported)))
                    }

                    if expiresAt.timeIntervalSinceNow > 0 {
                        try await scheduler.sleep(until: .init(.now() + .seconds(expiresAt.timeIntervalSinceNow)))
                        try Task.checkCancellation()
                        await backoff.reset()
                    } else {
                        try await backoff.next()
                    }
                } while !Task.isCancelled
            } catch is CancellationError {
                // Ignore CancellationError.
            } catch {
                subject.send(.failure(UX.Error(error: error)))
            }
            subject.send(completion: .finished)
        }
        return subject
            .handleEvents(receiveCancel: task.cancel)
            .eraseToAnyPublisher()
    }
}

private func dexQuoteRequest(
    input: DexQuoteInput,
    currenciesService: EnabledCurrenciesServiceAPI
) -> DexQuoteRequest? {
    guard let fromCurrency = quoteFromCurrency(amount: input.amount, currenciesService: currenciesService) else {
        return nil
    }
    guard let toCurrency = quoteToCurrency(input.destination, currenciesService: currenciesService) else {
        return nil
    }
    let params = quoteParams(slippage: input.slippage, skipValidation: input.skipValidation)
    return DexQuoteRequest(
        venue: .zeroX,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        takerAddress: input.takerAddress,
        params: params
    )
}

private func quoteParams(
    slippage: Double,
    skipValidation: Bool
) -> DexQuoteRequest.Params {
    DexQuoteRequest.Params(
        slippage: "\(slippage)",
        skipValidation: skipValidation
    )
}

private func quoteToCurrency(
    _ cryptoCurrency: CryptoCurrency?,
    currenciesService: EnabledCurrenciesServiceAPI
) -> DexQuoteRequest.ToCurrency? {
    guard let cryptoCurrency else {
        return nil
    }
    let address = cryptoCurrency.assetModel.kind.erc20ContractAddress
    guard let network = currenciesService.network(for: cryptoCurrency) else {
        return nil
    }
    return DexQuoteRequest.ToCurrency(
        chainId: Int(network.networkConfig.chainID),
        symbol: cryptoCurrency.code,
        address: address ?? Constants.nativeAssetAddress
    )
}

private func quoteFromCurrency(
    amount: CryptoValue?,
    currenciesService: EnabledCurrenciesServiceAPI
) -> DexQuoteRequest.FromCurrency? {
    guard let amount, amount.isPositive else {
        return nil
    }
    let cryptoCurrency = amount.currency
    let address = cryptoCurrency.assetModel.kind.erc20ContractAddress
    guard let network = currenciesService.network(for: cryptoCurrency) else {
        return nil
    }
    return DexQuoteRequest.FromCurrency(
        chainId: Int(network.networkConfig.chainID),
        symbol: cryptoCurrency.code,
        address: address ?? Constants.nativeAssetAddress,
        amount: amount.minorString
    )
}
