// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import DIKit
import MoneyKit
import PlatformKit
import RxSwift

final class BitcoinCashActivityDetailsInteractor {

    // MARK: - Private Properties

    private let notesService: BitcoinCashTxNotesStrategyAPI
    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails>

    // MARK: - Init

    init(
        notesService: BitcoinCashTxNotesStrategyAPI = resolve(),
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        detailsService: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails> = resolve()
    ) {
        self.notesService = notesService
        self.detailsService = detailsService
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
    }

    // MARK: - Public Functions

    private func note(for identifier: String) -> Single<String?> {
        notesService.note(txHash: identifier)
            .asSingle()
    }

    func updateNote(for identifier: String, to note: String?) -> Completable {
        notesService.updateNote(txHash: identifier, note: note)
            .asCompletable()
    }

    func details(identifier: String, createdAt: Date) -> Observable<BitcoinCashActivityDetailsViewModel> {
        let transaction = detailsService
            .details(for: identifier, cryptoCurrency: .bitcoinCash)
        let note = note(for: identifier)
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
            .map { BitcoinCashActivityDetailsViewModel(details: $0, price: $1?.moneyValue.fiatValue, note: $2) }
    }

    // MARK: - Private Functions

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
            of: CurrencyType.crypto(.bitcoinCash),
            in: fiatCurrency,
            at: .time(date)
        )
        .asSingle()
    }
}
