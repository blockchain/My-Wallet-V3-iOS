// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import ObservabilityKit

typealias DerivationReplenishement = (Wrapper, NativeWalletLoggerAPI) -> AnyPublisher<Wrapper, WalletError>

func provideDerivationReplenishment(
    tracer: LogMessageServiceAPI
) -> DerivationReplenishement {
    { [tracer] wrapper, logger in
        runDerivationsReplenishement(
            wrapper: wrapper,
            logger: logger
        )
        .handleEvents(receiveOutput: { _ in
            tracer.logInfo(message: "Derivation Replenishment Run")
        }, receiveCompletion: { completion in
            guard case .failure(let error) = completion else {
                return
            }
            tracer.logError(message: "Derivation Replenishment failed with error: \(error.errorDescription ?? "")")
        })
        .eraseToAnyPublisher()
    }
}

/// Recreates Accounts & Derivations for this wallet.
/// - Parameter wrapper: A `Wrapper` to be replenished
/// - Returns: A `Wrapper`
func runDerivationsReplenishement(
    wrapper: Wrapper,
    logger: NativeWalletLoggerAPI
) -> AnyPublisher<Wrapper, WalletError> {
    getMasterNode(from: wrapper.wallet)
        .publisher
        .mapError { _ in WalletError.initialization(.missingSeedHex) }
        .flatMap { [logger] masterNode -> AnyPublisher<HDWallet, WalletError> in
            guard let hdWallet = wrapper.wallet.defaultHDWallet else {
                return .failure(.initialization(.missingWallet))
            }
            logger.log(message: "[Replenishing] Adding missing derivations on accounts", metadata: nil)
            // run through the accounts of default HD Wallet
            // in case the accounts is empty, then create a new account with empty derivations to be filled
            let label = NonLocalizedConstants.defiWalletTitle
            let accounts = hdWallet.accounts.isEmpty
            ? [createAccount(label: label, index: 0, derivations: [])]
            : hdWallet.accounts

            let updatedAccounts = accounts.map { account -> Account in
                // creates the default derivations, see `DerivationType.defaultDerivations`
                let derivations = generateDerivations(
                    masterNode: masterNode,
                    index: account.index
                )
                // derivations include address label, which a customer might have reserved (via Web/Android)
                // this looks if the current derivation has address label and pass that in to the newly generated one.
                let updateDerivations = searchForAddressLabelsAndUpdate(
                    derivations: derivations,
                    account: account
                )
                return Account(
                    index: account.index,
                    label: account.label,
                    archived: account.archived,
                    defaultDerivation: .segwit,
                    derivations: updateDerivations
                )
            }
            let updatedHDWallet = HDWallet(
                seedHex: hdWallet.seedHex,
                passphrase: hdWallet.passphrase,
                mnemonicVerified: hdWallet.mnemonicVerified,
                defaultAccountIndex: hdWallet.defaultAccountIndex,
                accounts: updatedAccounts
            )
            return .just(updatedHDWallet)
        }
        .map { hdWallet in
            let wallet = NativeWallet(
                guid: wrapper.wallet.guid,
                sharedKey: wrapper.wallet.sharedKey,
                doubleEncrypted: wrapper.wallet.doubleEncrypted,
                doublePasswordHash: wrapper.wallet.doublePasswordHash,
                metadataHDNode: wrapper.wallet.metadataHDNode,
                options: wrapper.wallet.options,
                hdWallets: [hdWallet],
                addresses: wrapper.wallet.addresses,
                txNotes: wrapper.wallet.txNotes,
                addressBook: wrapper.wallet.addressBook
            )
            return Wrapper(
                pbkdf2Iterations: Int(wrapper.pbkdf2Iterations),
                version: wrapper.version,
                payloadChecksum: wrapper.payloadChecksum,
                language: wrapper.language,
                syncPubKeys: wrapper.syncPubKeys,
                wallet: wallet
            )
        }
        .logMessageOnOutput(logger: logger, message: { wrapper in
            "[Replenished] Wrapper: \(wrapper)"
        })
        .eraseToAnyPublisher()
}

private func searchForAddressLabelsAndUpdate(
    derivations: [Derivation],
    account: Account
) -> [Derivation] {
    derivations.map { derivation in
        guard let derivationType = derivation.type else {
            return derivation
        }
        let oldDerivationAddressLabels = account.derivation(for: derivationType)?.addressLabels ?? []
        return Derivation(
            type: derivation.type,
            purpose: derivation.purpose,
            xpriv: derivation.xpriv,
            xpub: derivation.xpub,
            addressLabels: oldDerivationAddressLabels,
            cache: derivation.cache
        )
    }
}

/// Checks if address cache xpub(s) are incorrect.
/// - Parameters:
///   - masterNode: The `masterNode` for derivations to be recreated
///   - accounts: The array of `Account`
/// - Returns: `true` if there are incorrect cache, otherwise `false`
func checkAddressCacheLegitimacy(
    masterNode: String,
    accounts: [Account]
) -> Bool {
    var affectedAccounts: [Account] = []
    for account in accounts {
        for derivation in account.derivations {
            guard let type = derivation.type else {
                continue
            }
            let correctDerivation = generateDerivation(
                type: type,
                index: account.index,
                masterNode: masterNode
            )
            if correctDerivation.cache != derivation.cache {
                affectedAccounts.append(account)
            }
        }
    }
    return affectedAccounts.isNotEmpty
}
