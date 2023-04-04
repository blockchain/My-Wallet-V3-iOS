// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumActivityDetailsInteractor {

    enum DetailsError: Error {
        case failed
    }

    // MARK: - Private Properties

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails>
    private let evmActivityRepository: EVMActivityRepositoryAPI
    private let txNotesStrategy: EthereumTxNotesStrategyAPI
    private let cryptoCurrency: CryptoCurrency
    private let network: EVMNetwork

    // MARK: - Init

    init(
        txNotesStrategy: EthereumTxNotesStrategyAPI = resolve(),
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        detailsService: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> = resolve(),
        evmActivityRepository: EVMActivityRepositoryAPI = resolve(),
        cryptoCurrency: CryptoCurrency,
        network: EVMNetwork
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.detailsService = detailsService
        self.evmActivityRepository = evmActivityRepository
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
        self.txNotesStrategy = txNotesStrategy
        self.network = network
    }

    // MARK: - Public Functions

    func updateNote(
        for identifier: String,
        to note: String?
    ) -> Completable {
        switch cryptoCurrency {
        case .ethereum:
            return txNotesStrategy.updateNote(
                txHash: identifier,
                note: note
            )
            .asCompletable()
        default:
            return .empty()
        }
    }

    func details(
        event: TransactionalActivityItemEvent
    ) -> AnyPublisher<EthereumActivityDetailsViewModel, Error> {
        switch cryptoCurrency {
        case .ethereum:
            return ethereumTransaction(event: event)
        default:
            return evmTransaction(event: event)
        }
    }

    // MARK: - Private Functions

    private func evmTransaction(
        event: TransactionalActivityItemEvent
    ) -> AnyPublisher<EthereumActivityDetailsViewModel, Error> {
        guard let sourceIdentifier = event.sourceIdentifier else {
            if BuildFlag.isInternal {
                fatalError("EVM Transaction \(event.transactionHash) without 'sourceIdentifier'.")
            }
            return .failure(DetailsError.failed)
        }
        let transaction = evmActivityRepository
            .transactions(network: network, cryptoCurrency: cryptoCurrency, address: sourceIdentifier)
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

        return transaction.combineLatest(price)
            .map { transaction, price in
                EthereumActivityDetailsViewModel(
                    details: transaction,
                    price: price
                )
            }
            .eraseToAnyPublisher()
    }

    private func ethereumTransaction(
        event: TransactionalActivityItemEvent
    ) -> AnyPublisher<EthereumActivityDetailsViewModel, Error> {
        let identifier = event.identifier
        let transaction = detailsService
            .details(
                for: identifier,
                cryptoCurrency: cryptoCurrency
            )
        let note = note(identifier: identifier)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        let price = price(
            of: cryptoCurrency,
            at: event.creationDate
        )
        .replaceError(with: nil)
        .eraseError()

        return Publishers
            .CombineLatest3(transaction, price, note)
            .map { transaction, price, note in
                EthereumActivityDetailsViewModel(
                    details: transaction,
                    price: price,
                    note: note
                )
            }
            .eraseToAnyPublisher()
    }

    private func note(identifier: String) -> AnyPublisher<String?, Never> {
        txNotesStrategy.note(txHash: identifier)
            .ignoreFailure()
            .mapError(to: Never.self)
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
}
