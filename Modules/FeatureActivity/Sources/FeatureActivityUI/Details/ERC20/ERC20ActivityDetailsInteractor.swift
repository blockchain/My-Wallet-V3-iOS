// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import MoneyKit
import PlatformKit
import ToolKit

final class ERC20ActivityDetailsInteractor {

    enum DetailsError: Error {
        case failed
    }

    // MARK: - Private Properties

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails>
    private let evmActivityRepository: EVMActivityRepositoryAPI
    private let cryptoCurrency: CryptoCurrency
    private let network: EVMNetwork

    // MARK: - Init

    init(
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        detailsService: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> = resolve(),
        evmActivityRepository: EVMActivityRepositoryAPI = resolve(),
        cryptoCurrency: CryptoCurrency,
        network: EVMNetwork
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.network = network
        self.detailsService = detailsService
        self.evmActivityRepository = evmActivityRepository
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
    }

    // MARK: - Public Functions

    func details(
        event: TransactionalActivityItemEvent
    ) -> AnyPublisher<ERC20ActivityDetailsViewModel, Error> {
        switch network {
        case .ethereum:
            return ethereumTransaction(event: event)
        default:
            return evmTransaction(event: event)
        }
    }

    // MARK: - Private Functions

    private func evmTransaction(
        event: TransactionalActivityItemEvent
    ) -> AnyPublisher<ERC20ActivityDetailsViewModel, Error> {
        guard let sourceIdentifier = event.sourceIdentifier else {
            if BuildFlag.isInternal {
                fatalError("EVM Transaction \(event.transactionHash) without 'sourceIdentifier'.")
            }
            return .failure(DetailsError.failed)
        }
        let transaction: AnyPublisher<EVMHistoricalTransaction, Error> = evmActivityRepository
            .transactions(
                network: network,
                cryptoCurrency: cryptoCurrency,
                address: sourceIdentifier
            )
            .map { transactions in
                transactions
                    .first(where: { $0.identifier == event.identifier })
            }
            .onNil(DetailsError.failed)
            .eraseError()
        let price = price(
            of: cryptoCurrency,
            at: event.creationDate
        )
        .replaceError(with: nil)
        .eraseError()
        let feePrice = self.price(
            of: feeCryptoCurrency,
            at: event.creationDate
        )
        .replaceError(with: nil)
        .eraseError()

        return Publishers
            .CombineLatest3(transaction, price, feePrice)
            .map { transaction, price, feePrice in
                ERC20ActivityDetailsViewModel(
                    details: transaction,
                    price: price,
                    feePrice: feePrice
                )
            }
            .eraseToAnyPublisher()
    }

    private func ethereumTransaction(
        event: TransactionalActivityItemEvent
    ) -> AnyPublisher<ERC20ActivityDetailsViewModel, Error> {
        let identifier = event.identifier
        let transaction = detailsService
            .details(
                for: identifier,
                cryptoCurrency: cryptoCurrency
            )
        let price = price(
            of: cryptoCurrency,
            at: event.creationDate
        )
        .replaceError(with: nil)
        .eraseError()
        let feePrice = self.price(
            of: feeCryptoCurrency,
            at: event.creationDate
        )
        .replaceError(with: nil)
        .eraseError()

        return Publishers
            .CombineLatest3(transaction, price, feePrice)
            .map { transaction, price, feePrice in
                ERC20ActivityDetailsViewModel(
                    details: transaction,
                    price: price,
                    feePrice: feePrice
                )
            }
            .eraseToAnyPublisher()
    }

    private func price(
        of cryptoCurrency: CryptoCurrency,
        at date: Date
    ) -> AnyPublisher<FiatValue?, PriceServiceError> {
        fiatCurrencySettings
            .displayCurrency
            .setFailureType(to: PriceServiceError.self)
            .flatMap { [priceService] fiatCurrency in
                priceService.price(
                    of: cryptoCurrency,
                    in: fiatCurrency,
                    at: .time(date)
                )
            }
            .map { quote -> FiatValue? in
                quote.moneyValue.fiatValue
            }
            .eraseToAnyPublisher()
    }

    var feeCryptoCurrency: CryptoCurrency {
        network.nativeAsset
    }
}
