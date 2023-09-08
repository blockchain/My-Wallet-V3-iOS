// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit
import WalletPayloadKit

public protocol BitcoinCashTxNotesStrategyAPI: TxNoteUpdateProvideStrategyAPI {}

final class BitcoinCashTxNotesStrategy: BitcoinCashTxNotesStrategyAPI {

    private let repository: BitcoinCashWalletAccountRepository
    private let updater: BitcoinCashEntryFetcherAPI

    init(
        repository: BitcoinCashWalletAccountRepository,
        updater: BitcoinCashEntryFetcherAPI
    ) {
        self.repository = repository
        self.updater = updater
    }

    func note(
        txHash: String
    ) -> AnyPublisher<String?, TxNotesError> {
        repository.bitcoinCashEntry
            .mapError { _ in TxNotesError.unableToRetrieveNote }
            .compactMap { $0 }
            .map { entry in
                entry.txNotes?[txHash]
            }
            .first()
            .eraseToAnyPublisher()
    }

    func updateNote(
        txHash: String,
        note: String?
    ) -> AnyPublisher<EmptyValue, TxNotesError> {
        repository.bitcoinCashEntry
            .first()
            .mapError { _ in TxNotesError.unableToRetrieveNote }
            .compactMap { $0 }
            .map { entry -> BitcoinCashEntry in
                let notes = entry.txNotes
                let updatedNotes = transcationNotesUpdate(notes: notes, hash: txHash, note: note)
                return BitcoinCashEntry(
                    payload: entry.payload,
                    accounts: entry.accounts,
                    importedAddress: entry.importedAddress,
                    txNotes: updatedNotes
                )
            }
            .flatMap { [updater] updatedEntry -> AnyPublisher<EmptyValue, TxNotesError> in
                updater.update(entry: updatedEntry)
                    .mapError { _ in TxNotesError.unabledToSave }
                    .eraseToAnyPublisher()
            }
            .handleEvents(
                receiveCompletion: { [repository] completion in
                    guard case .finished = completion else {
                        return
                    }
                    repository.invalidateCache()
                }
            )
            .eraseToAnyPublisher()
    }
}
