// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import DIKit
import MoneyKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - BitcoinKit Module

    public static var stellarKit = module {

        factory { () -> HorizonProxyAPI in
            HorizonProxy(
                configurationService: DIKit.resolve()
            )
        }

        single { () -> StellarConfigurationServiceAPI in
            StellarConfigurationService(app: DIKit.resolve())
        }

        single { () -> StellarWalletAccountRepositoryAPI in
            StellarWalletAccountRepository(
                metadataEntryService: DIKit.resolve(),
                mnemonicAccessAPI: DIKit.resolve()
            )
        }

        factory(tag: CryptoCurrency.stellar) { () -> CryptoAsset in
            StellarAsset(
                accountRepository: DIKit.resolve(),
                errorRecorder: DIKit.resolve(),
                exchangeAccountProvider: DIKit.resolve(),
                kycTiersService: DIKit.resolve(),
                addressFactory: DIKit.resolve()
            )
        }

        single { () -> FeesRepositoryAPI in
            FeesRepository(
                client: FeesClient(networkAdapter: DIKit.resolve(), requestBuilder: DIKit.resolve())
            )
        }

        factory { () -> StellarTransactionDispatcherAPI in
            StellarTransactionDispatcher(
                app: DIKit.resolve(),
                accountRepository: DIKit.resolve(),
                horizonProxy: DIKit.resolve()
            )
        }

        factory { StellarCryptoReceiveAddressFactory() }

        factory(tag: AddressFactoryTag.stellar) { () -> ExternalAssetAddressFactory in
            StellarCryptoReceiveAddressFactory() as ExternalAssetAddressFactory
        }
    }
}
