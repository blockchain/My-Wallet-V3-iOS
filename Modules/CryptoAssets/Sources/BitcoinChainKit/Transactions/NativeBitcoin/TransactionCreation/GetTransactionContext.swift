// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import ToolKit
import WalletCore
import YenomBitcoinKit

struct NativeBitcoinTransactionContext {
    let accountKeyContext: AccountKeyContextProtocol
    let unspentOutputs: [UnspentOutput]
    let multiAddressItems: [AddressItem]
    let coin: BitcoinChainCoin
    let keyPairs: [WalletKeyPair]
    let imported: Bool

    init(accountKeyContext: AccountKeyContextProtocol, unspentOutputs: [UnspentOutput], multiAddressItems: [AddressItem], coin: BitcoinChainCoin, imported: Bool) {
        self.accountKeyContext = accountKeyContext
        self.unspentOutputs = unspentOutputs
        self.multiAddressItems = multiAddressItems
        self.coin = coin
        self.imported = imported
        if !imported {
            self.keyPairs = getWalletKeyPairs(
                unspentOutputs: unspentOutputs,
                accountKeyContext: accountKeyContext
            )
        } else {
            self.keyPairs = [
                WalletKeyPair(
                    xpriv: accountKeyContext.defaultDerivation(coin: coin).xpriv,
                    privateKeyData: WalletCore.Base58.decodeNoCheck(string: accountKeyContext.defaultDerivation(coin: coin).xpriv) ?? Data(),
                    xpub: XPub(address: accountKeyContext.defaultDerivation(coin: coin).xpub, derivationType: .legacy)
                )
            ]
        }
    }
}

typealias TransactionContextFor =
    (BitcoinChainAccount) -> AnyPublisher<NativeBitcoinTransactionContext, Error>

func getTransactionContext(
    for account: BitcoinChainAccount,
    transactionContextFor: TransactionContextFor
) -> AnyPublisher<NativeBitcoinTransactionContext, Error> {
    transactionContextFor(account)
}

func getTransactionContextProvider(
    walletMnemonicProvider: @escaping WalletMnemonicProvider,
    fetchUnspentOutputsFor: @escaping FetchUnspentOutputsFor,
    fetchMultiAddressFor: @escaping FetchMultiAddressFor
) -> (BitcoinChainAccount) -> AnyPublisher<NativeBitcoinTransactionContext, Error> {
    { [walletMnemonicProvider] account in
        getAccountKeysOrImportedAddressContext(
            account: account,
            walletMnemonicProvider: walletMnemonicProvider
        )
        .flatMap { context -> AnyPublisher<NativeBitcoinTransactionContext, Error> in
            let xpubs = context.xpubs
            let unspentOutputsPublisher = getUnspentOutputs(
                for: account,
                xpubs: xpubs,
                fetchUnspentOutputsFor: fetchUnspentOutputsFor
            )
            let multiAddressPublisher = getMultiAddress(
                xpubs: xpubs,
                fetchMultiAddressFor: fetchMultiAddressFor
            )
            return Publishers.Zip(unspentOutputsPublisher, multiAddressPublisher)
                .map { unspentOutputs, addressItems in
                    (context, unspentOutputs, addressItems, account.coin)
                }
                .map { context, unspentOutputs, addressItems, coin in
                    NativeBitcoinTransactionContext(
                        accountKeyContext: context,
                        unspentOutputs: unspentOutputs,
                        multiAddressItems: addressItems,
                        coin: coin,
                        imported: account.isImported
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

enum ImportedAccountContextError: Error {
    case missingPrivateKey
    case missingXpub
}

private func getAccountKeysOrImportedAddressContext(
    account: BitcoinChainAccount,
    walletMnemonicProvider: @escaping WalletMnemonicProvider
) -> AnyPublisher<AccountKeyContextProtocol, Error> {
    if account.isImported {
        guard let priv = account.importedPrivateKey, priv.isNotEmpty else {
            return .failure(ImportedAccountContextError.missingPrivateKey)
        }
        guard let xpub = account.xpub else {
            return .failure(ImportedAccountContextError.missingXpub)
        }
        return .just(
            ImportedAccountKeyContext(
                coin: account.coin.derivationCoinType,
                accountIndex: UInt32(account.index),
                xPub: xpub,
                priv: priv
            )
        )
    } else {
        return getAccountKeys(
            for: account,
            walletMnemonicProvider: walletMnemonicProvider
        )
        .eraseToAnyPublisher()
    }
}

private func getUnspentOutputs(
    for account: BitcoinChainAccount,
    xpubs: [XPub],
    fetchUnspentOutputsFor: FetchUnspentOutputsFor
) -> AnyPublisher<[UnspentOutput], Error> {
    fetchUnspentOutputsFor(xpubs)
        .map(\.outputs)
        .eraseError()
}
