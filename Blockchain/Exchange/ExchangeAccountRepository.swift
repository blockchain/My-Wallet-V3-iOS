// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit

final class ExchangeAccountRepository: ExchangeAccountRepositoryAPI {

    private let nabuUserService: NabuUserServiceAPI
    private let client: ExchangeClientAPI
    private let coincore: CoincoreAPI

    private var hasLinkedExchangeAccount: AnyPublisher<Bool, ExchangeAccountRepositoryError> {
        nabuUserService.user
            .map(\.hasLinkedExchangeAccount)
            .replaceError(with: ExchangeAccountRepositoryError.failedCheckLinkedExchange)
    }

    init(
        nabuUserService: NabuUserServiceAPI = resolve(),
        client: ExchangeClientAPI = resolve(),
        coincore: CoincoreAPI = resolve()
    ) {
        self.nabuUserService = nabuUserService
        self.client = client
        self.coincore = coincore
    }

    func syncDepositAddressesIfLinked() -> AnyPublisher<Void, ExchangeAccountRepositoryError> {
        Just(())
            .delay(for: .seconds(15), scheduler: DispatchQueue.main)
            .flatMap { [hasLinkedExchangeAccount] in
                hasLinkedExchangeAccount
            }
            .flatMap { [syncDepositAddresses] isLinked -> AnyPublisher<Void, ExchangeAccountRepositoryError> in
                guard isLinked else {
                    return .just(())
                }
                return syncDepositAddresses()
            }
            .eraseToAnyPublisher()
    }

    private func syncDepositAddresses() -> AnyPublisher<Void, ExchangeAccountRepositoryError> {
        cryptoReceiveAddressesToSync()
            .flatMap { [client] addresses -> AnyPublisher<Void, ExchangeAccountRepositoryError> in
                client.syncDepositAddress(accounts: addresses)
                    .replaceError(with: ExchangeAccountRepositoryError.failedToSyncAddresses)
            }
            .eraseToAnyPublisher()
    }

    /// CryptoReceiveAddress array that should be synced to the Exchange.
    private func cryptoReceiveAddressesToSync() -> AnyPublisher<[CryptoReceiveAddress], Never> {
        accountsToSync()
            .flatMap { accounts -> AnyPublisher<[ReceiveAddress?], Never> in
                accounts
                    .map { account in
                        account.receiveAddress
                            .optional()
                            .replaceError(with: nil)
                    }
                    .zip()
            }
            .map { addresses -> [CryptoReceiveAddress] in
                addresses.compactMap { address in
                    address as? CryptoReceiveAddress
                }
            }
            .eraseToAnyPublisher()
    }

    /// SingleAccount array that should sync their Receive Address to the Exchange.
    private func accountsToSync() -> AnyPublisher<[SingleAccount], Never> {
        Deferred { [coincore] in
            Future<[CryptoAsset], Never> { promise in
                let cryptoAssets = coincore.cryptoAssets
                    .filter {
                        $0.asset.assetModel.supports(product: .mercuryDeposits)
                            || $0.asset.assetModel.supports(product: .mercuryWithdrawals)
                    }
                promise(.success(cryptoAssets))
            }
        }
        .flatMap { cryptoAssets in
            cryptoAssets
                .map { asset in
                    asset.defaultAccount.optional().replaceError(with: nil)
                }
                .zip()
                .map { accounts in
                    accounts.compactMap { $0 }
                }
        }
        .eraseToAnyPublisher()
    }
}
