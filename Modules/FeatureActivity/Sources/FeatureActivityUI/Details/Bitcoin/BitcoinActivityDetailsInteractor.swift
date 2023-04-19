// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinKit
import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

enum BitcoinActivityDetailsError: Error {
    case unableToRetrieveNote
    case unableToSaveNote
}

final class BitcoinActivityDetailsInteractor {

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails>
    private let bitcoinTxNoteService: BitcoinTxNotesStrategyAPI

    init(
        bitcoinTxNoteService: BitcoinTxNotesStrategyAPI = resolve(),
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        detailsService: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> = resolve()
    ) {
        self.bitcoinTxNoteService = bitcoinTxNoteService
        self.detailsService = detailsService
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
    }

    private func note(for identifier: String) -> AnyPublisher<String?, BitcoinActivityDetailsError> {
        bitcoinTxNoteService.note(txHash: identifier)
            .mapError { _ in BitcoinActivityDetailsError.unableToRetrieveNote }
            .eraseToAnyPublisher()
    }

    func updateNote(
        for identifier: String,
        to note: String?
    ) -> AnyPublisher<EmptyValue, BitcoinActivityDetailsError> {
        bitcoinTxNoteService.updateNote(txHash: identifier, note: note)
            .mapError { _ in BitcoinActivityDetailsError.unableToRetrieveNote }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func price(at date: Date) -> Single<PriceQuoteAtTime> {
        fiatCurrencySettings
            .displayCurrency
            .asSingle()
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.price(at: date, in: fiatCurrency)
            }
    }

    private func price(at date: Date, in fiatCurrency: FiatCurrency) -> Single<PriceQuoteAtTime> {
        priceService.price(
            of: CurrencyType.crypto(.bitcoin),
            in: fiatCurrency,
            at: .time(date)
        )
        .asSingle()
    }

    func details(identifier: String, createdAt: Date) -> Observable<BitcoinActivityDetailsViewModel> {
        let transaction = detailsService
            .details(for: identifier, cryptoCurrency: .bitcoin)
        let note = note(for: identifier)
            .asSingle()
            .catchAndReturn(nil)
        let price = price(at: createdAt)
            .optional()
            .catchAndReturn(nil)

        return Observable
            .combineLatest(
                transaction.asObservable(),
                price.asObservable(),
                note.asObservable()
            )
            .map { BitcoinActivityDetailsViewModel(details: $0, price: $1?.moneyValue.fiatValue, note: $2) }
    }
}
