// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureAuthenticationDomain
import FeatureCardPaymentDomain
import FeatureSettingsDomain
import FeatureWithdrawalLocksData
import FeatureWithdrawalLocksDomain
import MoneyKit
import PlatformKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - FeatureAppDomain Module

    public static var featureAppDomain = module {

        single { () -> AnalyticsKit.TokenProvider in
            let tokenRepository: NabuTokenRepositoryAPI = DIKit.resolve()
            return { tokenRepository.sessionToken } as AnalyticsKit.TokenProvider
        }

        single { () -> FeatureAuthenticationDomain.NabuUserEmailProvider in
            let service: SettingsServiceAPI = DIKit.resolve()
            return { () -> AnyPublisher<String, Error> in
                service
                    .singleValuePublisher
                    .map(\.email)
                    .eraseError()
                    .eraseToAnyPublisher()
            } as FeatureAuthenticationDomain.NabuUserEmailProvider
        }

        factory { () -> WalletStateProvider in
            let holder: WalletHolderAPI = DIKit.resolve()
            return WalletStateProvider.live(
                holder: holder
            )
        }

        // MARK: Withdrawal Lock

        factory {
            MoneyValueFormatterAdapter() as MoneyValueFormatterAPI
        }

        factory {
            CryptoValueFormatterAdapter() as CryptoValueFormatterAPI
        }

        factory {
            FiatCurrencyCodeProviderAdapter(fiatCurrencyPublisher: DIKit.resolve()) as FiatCurrencyCodeProviderAPI
        }

        factory {
            ApplePayAdapter(
                app: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                eligibleMethodsClient: DIKit.resolve(),
                tiersService: DIKit.resolve()
            ) as ApplePayEligibleServiceAPI
        }

        factory {
            ReferralsAdapter(
                referralService: DIKit.resolve()
            ) as ReferralAdapterAPI
        }
    }
}
