// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - BitcoinKit Module

    public static var stellarKit = module {

        factory { () -> HorizonProxyAPI in
            HorizonProxy(
                configurationService: DIKit.resolve(),
                accountRepository: DIKit.resolve(),
                walletOptions: DIKit.resolve()
            )
        }

        single { () -> StellarConfigurationServiceAPI in
            StellarConfigurationService(walletOptions: DIKit.resolve())
        }

        factory { () -> StellarWalletOptionsBridgeAPI in
            StellarWalletOptionsService(walletOptions: DIKit.resolve())
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

        single { AnyCryptoFeeRepository(repository: CryptoFeeRepository<StellarTransactionFee>()) }

        factory { () -> StellarTransactionDispatcherAPI in
            StellarTransactionDispatcher(
                accountRepository: DIKit.resolve(),
                walletOptions: DIKit.resolve(),
                horizonProxy: DIKit.resolve()
            )
        }

        factory { StellarCryptoReceiveAddressFactory() }

        factory(tag: AddressFactoryTag.stellar) { () -> ExternalAssetAddressFactory in
            StellarCryptoReceiveAddressFactory() as ExternalAssetAddressFactory
        }
    }
}
