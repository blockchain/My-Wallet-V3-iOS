// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BINDWithdrawData
import BINDWithdrawDomain
import DIKit
import FeatureTransactionDomain
import NetworkKit

extension DependencyContainer {

    // MARK: - FeatureTransactionData Module

    public static var featureTransactionData = module {

        // MARK: - Data

        single { BrokerageQuoteService(repository: DIKit.resolve()) }

        factory {
            BrokerageQuoteRepository(
                requestBuilder: DIKit.resolve(tag: DIKitContext.retail),
                network: DIKit.resolve(tag: DIKitContext.retail)
            ) as BrokerageQuoteRepositoryProtocol
        }

        factory { FiatWithdrawRepository() as FiatWithdrawRepositoryAPI }

        factory { CustodialTransferRepository() as CustodialTransferRepositoryAPI }

        factory { OrderQuoteRepository() as OrderQuoteRepositoryAPI }

        factory { OrderCreationRepository() as OrderCreationRepositoryAPI }

        factory { OrderUpdateRepository() as OrderUpdateRepositoryAPI }

        factory { OrderFetchingRepository() as OrderFetchingRepositoryAPI }

        single { () -> TransactionLimitsRepositoryAPI in
            TransactionLimitsRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> CancelRecurringBuyRepositoryAPI in
            CancelRecurringBuyRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> EligiblePaymentMethodRecurringBuyRepositoryAPI in
            EligiblePaymentMethodRecurringBuyRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> RecurringBuyProviderRepositoryAPI in
            RecurringBuyProviderRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> WithdrawalLocksCheckRepositoryAPI in
            WithdrawalLocksCheckRepository(
                client: DIKit.resolve()
            )
        }

        factory { BitPayRepository() as BitPayRepositoryAPI }

        factory { AvailablePairsRepository() as AvailablePairsRepositoryAPI }

        factory { BankTransferRepository() as BankTransferRepositoryAPI }

        factory { BlockchainNameResolutionRepository() as BlockchainNameResolutionRepositoryAPI }

        // MARK: - Network

        factory { APIClient() as FeatureTransactionDomainClientAPI }

        factory { () -> OrderCreationClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as OrderCreationClientAPI
        }

        factory { () -> RecurringBuyProviderClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as RecurringBuyProviderClientAPI
        }

        factory { () -> CancelRecurringBuyClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as CancelRecurringBuyClientAPI
        }

        factory { () -> EligiblePaymentMethodRecurringBuyClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as EligiblePaymentMethodRecurringBuyClientAPI
        }

        factory { () -> OrderUpdateClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as OrderUpdateClientAPI
        }

        factory { () -> CustodialQuoteAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as CustodialQuoteAPI
        }

        factory { () -> TransactionLimitsClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as TransactionLimitsClientAPI
        }

        factory { () -> WithdrawalLocksCheckClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as WithdrawalLocksCheckClientAPI
        }

        factory { () -> AvailablePairsClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as AvailablePairsClientAPI
        }

        factory { () -> OrderFetchingClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as OrderFetchingClientAPI
        }

        factory { () -> CustodialTransferClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as CustodialTransferClientAPI
        }

        factory { () -> BitPayClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as BitPayClientAPI
        }

        factory { () -> BankTransferClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as BankTransferClientAPI
        }

        factory { () -> BlockchainNameResolutionClientAPI in
            let client: FeatureTransactionDomainClientAPI = DIKit.resolve()
            return client as BlockchainNameResolutionClientAPI
        }

        factory {
            BINDWithdrawRepository(
                requestBuilder: DIKit.resolve(tag: DIKitContext.retail),
                network: DIKit.resolve(tag: DIKitContext.retail)
            ) as BINDWithdrawRepositoryProtocol
        }
    }
}
