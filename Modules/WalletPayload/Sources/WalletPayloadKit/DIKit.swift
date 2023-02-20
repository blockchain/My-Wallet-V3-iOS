// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import MetadataKit
import ObservabilityKit

enum WalletRepoOperationsQueue {
    static let queueTag = "op.queue.tag"
}

extension DependencyContainer {

    // MARK: - WalletPayloadKit Module

    public static var walletPayloadKit = module {

        single(tag: WalletRepoOperationsQueue.queueTag) { () -> DispatchQueue in
            DispatchQueue(label: "wallet.payload.operations.queue")
        }

        factory { () -> ForgetWalletAPI in
            ForgetWallet(
                legacyForgetWallet: DIKit.resolve(),
                walletRepo: DIKit.resolve(),
                walletState: DIKit.resolve(),
                walletPersistence: DIKit.resolve()
            )
        }

        single { () -> WalletSyncAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.sync.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletSync(
                walletHolder: DIKit.resolve(),
                walletRepo: DIKit.resolve(),
                payloadCrypto: PayloadCrypto(cryptor: AESCryptor()),
                walletEncoder: DIKit.resolve(),
                saveWalletRepository: DIKit.resolve(),
                syncPubKeysAddressesProvider: DIKit.resolve(),
                tracer: DIKit.resolve(),
                logger: DIKit.resolve(),
                operationQueue: queue,
                checksumProvider: checksumHex(data:)
            )
        }

        factory { () -> WalletFetcherAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.fetching.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletFetcher(
                walletRepo: DIKit.resolve(),
                payloadCrypto: DIKit.resolve(),
                walletLogic: DIKit.resolve(),
                walletPayloadRepository: DIKit.resolve(),
                operationsQueue: queue,
                tracer: DIKit.resolve(),
                logger: DIKit.resolve()
            )
        }

        factory { () -> WalletUpgraderAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.upgrading.op.queue", qos: .userInitiated, target: targetQueue)
            let version3Flow = Version3Workflow(
                entropyService: DIKit.resolve(),
                logger: DIKit.resolve(),
                operationQueue: queue
            )
            let version4Flow = Version4Workflow(
                logger: DIKit.resolve()
            )
            return WalletUpgrader(
                workflows: [version3Flow, version4Flow]
            )
        }

        factory { () -> WalletLogic in
            let walletCreator: WalletDecoderAPI = DIKit.resolve()
            let decoder = walletCreator.createWallet
            let upgrader: WalletUpgraderAPI = DIKit.resolve()
            let tracer: LogMessageServiceAPI = DIKit.resolve()
            let traceMethod = tracer.logError(message:)
            let walletCredentialsFetcher: WalletCredentialsFetcher = DIKit.resolve()
            let credentialsSaveIfNeeded = walletCredentialsFetcher.saveIfNeeded
            return WalletLogic(
                holder: DIKit.resolve(),
                decoder: decoder,
                upgrader: upgrader,
                metadata: DIKit.resolve(),
                walletSync: DIKit.resolve(),
                notificationCenter: .default,
                logger: DIKit.resolve(),
                payloadHealthChecker: walletPayloadHealthCheckProvider(tracer: traceMethod),
                checkAndSaveWalletCredentials: credentialsSaveIfNeeded,
                derivationReplenishement: provideDerivationReplenishment(tracer: tracer)
            )
        }

        factory { () -> WalletRecoveryServiceAPI in
            let walletLogic: WalletLogic = DIKit.resolve()
            let payloadCrypto: PayloadCryptoAPI = DIKit.resolve()
            let repo: WalletRepoAPI = DIKit.resolve()
            let payloadRepository: WalletPayloadRepositoryAPI = DIKit.resolve()
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.recovery.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletRecoveryService(
                walletLogic: walletLogic,
                payloadCrypto: payloadCrypto,
                walletRepo: repo,
                walletPayloadRepository: payloadRepository,
                operationsQueue: queue,
                tracer: DIKit.resolve()
            )
        }

        factory { () -> WalletCreatorAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.creation.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletCreator(
                entropyService: DIKit.resolve(),
                walletEncoder: DIKit.resolve(),
                encryptor: PayloadCrypto(cryptor: AESCryptor()),
                createWalletRepository: DIKit.resolve(),
                usedAccountsFinder: DIKit.resolve(),
                operationQueue: queue,
                logger: DIKit.resolve(),
                tracer: DIKit.resolve(),
                uuidProvider: uuidProvider,
                generateWallet: generateWallet(context:),
                generateWrapper: generateWrapper(wallet:language:version:),
                checksumProvider: checksumHex(data:)
            )
        }

        factory { () -> SecondPasswordServiceAPI in
            SecondPasswordService(walletHolder: DIKit.resolve())
        }

        factory { () -> WalletMetadataEntryServiceAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: MetadataServiceAPI = DIKit.resolve()
            let queue = DispatchQueue(label: "wallet.metadata.operations.queue")
            return WalletMetadataEntryService(
                walletHolder: holder,
                metadataService: metadata,
                logger: DIKit.resolve(),
                queue: queue
            )
        }

        factory { () -> WalletConnectFetcherAPI in
            let metadataEntryService: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return WalletConnectFetcher(
                metadataEntryService: metadataEntryService
            )
        }

        single { () -> UserCredentialsFetcherAPI in
            let metadataEntryService: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return UserCredentialsFetcher(
                metadataEntryService: metadataEntryService
            )
        }

        single { () -> AccountCredentialsFetcherAPI in
            let metadataEntryService: WalletMetadataEntryServiceAPI = DIKit.resolve()
            let userCredentialsFetcher: UserCredentialsFetcherAPI = DIKit.resolve()
            return AccountCredentialsFetcher(
                metadataEntryService: metadataEntryService,
                userCredentialsFetcher: userCredentialsFetcher,
                featureFlagService: DIKit.resolve()
            )
        }

        factory { () -> WalletCredentialsFetcher in
            WalletCredentialsFetcher(
                service: DIKit.resolve(),
                tracer: DIKit.resolve()
            )
        }

        factory { () -> BitcoinCashEntryFetcherAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return BitcoinCashEntryFetcher(
                walletHolder: holder,
                metadataEntryService: metadata
            )
        }

        factory { () -> BitcoinEntryFetcherAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return BitcoinEntryFetcher(
                walletHolder: holder,
                metadataEntryService: metadata
            )
        }

        factory { () -> AccountNamingReplenishementAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "account.renaming.op.queue", qos: .userInitiated, target: targetQueue)
            return AccountRenamingReplenishement(
                walletHolder: DIKit.resolve(),
                walletSync: DIKit.resolve(),
                walletRepo: DIKit.resolve(),
                logger: DIKit.resolve(),
                operationQueue: queue
            )
        }

        factory { () -> RNGServiceAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "rng.service.op.queue", qos: .userInitiated, target: targetQueue)
            return RNGService(
                serverEntropyRepository: DIKit.resolve(),
                localEntropyProvider: provideLocalEntropy(bytes:),
                combineEntropyParsing: combineEntropies(local:remote:),
                operationQueue: queue
            )
        }

        factory { () -> WalletCoreHDWalletProvider in
            let walletHolder: WalletHolderAPI = DIKit.resolve()
            return provideWalletCoreHDWallet(
                walletHolder: walletHolder
            )
        }

        factory { () -> ChangePasswordServiceAPI in
            let walletCredentialsFetcher: WalletCredentialsFetcher = DIKit.resolve()
            let credentialsSaveIfNeeded = walletCredentialsFetcher.saveIfNeeded
            return ChangePasswordService(
                walletSync: DIKit.resolve(),
                walletHolder: DIKit.resolve(),
                saveMetadataWalletCredetials: credentialsSaveIfNeeded,
                logger: DIKit.resolve()
            )
        }

        factory { () -> VerifyMnemonicBackupServiceAPI in
            VerifyMnemonicBackupService(
                walletHolder: DIKit.resolve(),
                walletSync: DIKit.resolve(),
                walletRepo: DIKit.resolve(),
                logger: DIKit.resolve()
            )
        }

        single { () -> MnemonicAccessAPI in
            MnemonicAccessService(
                walletHolder: DIKit.resolve()
            )
        }

        factory { () -> MnemonicVerificationStatusProvider in
            provideMnemonicVerificationStatus(
                walletHolder: DIKit.resolve()
            )
        }

        factory { MnemonicComponentsProvider() as MnemonicComponentsProviding }

        factory { WalletCryptoService() as WalletCryptoServiceAPI }

        factory { WalletPayloadCryptor() as WalletPayloadCryptorAPI }

        factory { PayloadCrypto() as PayloadCryptoAPI }

        factory { AESCryptor() as AESCryptorAPI }
    }
}
