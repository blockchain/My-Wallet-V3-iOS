// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ObservabilityKit

public typealias AccountToRename = (index: Int, label: String)

public protocol AccountNamingReplenishementAPI {
    func updateLabels(on accounts: [AccountToRename]) -> AnyPublisher<Void, AccountRenamingError>
}

public enum AccountRenamingError: Error {
    case notInitialized
    case syncFailure(WalletSyncError)
}

public class AccountRenamingReplenishement: AccountNamingReplenishementAPI {

    private let walletHolder: WalletHolderAPI
    private let walletSync: WalletSyncAPI
    private let walletRepo: WalletRepoAPI
    private let logger: NativeWalletLoggerAPI
    private let operationQueue: DispatchQueue

    init(
        walletHolder: WalletHolderAPI,
        walletSync: WalletSyncAPI,
        walletRepo: WalletRepoAPI,
        logger: NativeWalletLoggerAPI,
        operationQueue: DispatchQueue
    ) {
        self.walletHolder = walletHolder
        self.walletSync = walletSync
        self.walletRepo = walletRepo
        self.logger = logger
        self.operationQueue = operationQueue
    }

    public func updateLabels(on accounts: [AccountToRename]) -> AnyPublisher<Void, AccountRenamingError> {
        getWrapper(walletHolder: walletHolder)
            .zip(walletRepo.get().map(\.credentials.password).mapError(to: WalletError.self))
            .receive(on: operationQueue)
            .mapError { _ in AccountRenamingError.notInitialized }
            .logMessageOnOutput(logger: logger) { wrapper, _ in
                "[AccountRenaming] About to update accounts on wrapper: \(wrapper)"
            }
            .map { currentWrapper, password -> (Wrapper?, String) in
                let currentWallet = currentWrapper.wallet
                guard let hdWallet = currentWallet.defaultHDWallet else {
                    return (nil, password)
                }
                let updatedAccounts = hdWallet.accounts.map { account in
                    if let label = accounts.first(where: { $0.index == account.index })?.label {
                        return updateLabel(on: account, newLabel: label)
                    } else {
                        return account
                    }
                }
                let updatedHDWallet = updateHDWallet(current: hdWallet, accounts: updatedAccounts)
                let updatedWallet = updateWallet(currentWallet: currentWallet, hdWallet: updatedHDWallet)
                let updatedWrapper = updateWrapper(nativeWallet: updatedWallet)(currentWrapper)
                return (updatedWrapper, password)
            }
            .logMessageOnOutput(logger: logger) { wrapper, _ in
                "[AccountRenaming] Wrapper updated: \(String(describing: wrapper))"
            }
            .flatMap { [walletSync] wrapper, password -> AnyPublisher<Void, AccountRenamingError> in
                guard let wrapper = wrapper else {
                    return .failure(.syncFailure(.unknown))
                }
                return walletSync.sync(wrapper: wrapper, password: password)
                    .mapToVoid()
                    .mapError(AccountRenamingError.syncFailure)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

func updateWallet(currentWallet: NativeWallet, hdWallet: HDWallet) -> NativeWallet {
    NativeWallet(
        guid: currentWallet.guid,
        sharedKey: currentWallet.sharedKey,
        doubleEncrypted: currentWallet.doubleEncrypted,
        doublePasswordHash: currentWallet.doublePasswordHash,
        metadataHDNode: currentWallet.metadataHDNode,
        options: currentWallet.options,
        hdWallets: [hdWallet],
        addresses: currentWallet.addresses,
        txNotes: currentWallet.txNotes,
        addressBook: currentWallet.addressBook
    )
}

func updateHDWallet(current: HDWallet, accounts: [Account]) -> HDWallet {
    HDWallet(
        seedHex: current.seedHex,
        passphrase: current.passphrase,
        mnemonicVerified: current.mnemonicVerified,
        defaultAccountIndex: current.defaultAccountIndex,
        accounts: accounts
    )
}

func updateLabel(on account: Account, newLabel: String) -> Account {
    Account(
        index: account.index,
        label: newLabel,
        archived: account.archived,
        defaultDerivation: account.defaultDerivation,
        derivations: account.derivations
    )
}
