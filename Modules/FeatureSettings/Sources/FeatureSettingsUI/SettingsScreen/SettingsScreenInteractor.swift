// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class SettingsScreenInteractor {

    // MARK: - Interactors

    let emailVerificationBadgeInteractor: EmailVerificationBadgeInteractor
    let mobileVerificationBadgeInteractor: MobileVerificationBadgeInteractor
    let twoFactorVerificationBadgeInteractor: TwoFactorVerificationBadgeInteractor
    let preferredCurrencyBadgeInteractor: PreferredCurrencyBadgeInteractor
    let preferredTradingCurrencyBadgeInteractor: PreferredTradingCurrencyBadgeInteractor
    let cardSectionInteractor: CardSettingsSectionInteractor
    let bankSectionInteractor: BanksSettingsSectionInteractor
    let blockchainDomainsAdapter: BlockchainDomainsAdapter
    let referralAdapter: ReferralAdapterAPI

    // MARK: - Services

    // TODO: All interactors should be created inside this class,
    /// and services should be injected into them through the main class.
    /// The presenter should not contain any interaction logic

    let settingsService: SettingsServiceAPI
    let smsTwoFactorService: SMSTwoFactorSettingsServiceAPI

    let tiersProviding: TierLimitsProviding
    let settingsAuthenticating: AppSettingsAuthenticating
    let biometryProviding: BiometryProviding
    let credentialsStore: CredentialsStoreAPI
    let recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding
    let authenticationCoordinator: AuthenticationCoordinating

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    init(
        credentialsStore: CredentialsStoreAPI = resolve(),
        settingsService: SettingsServiceAPI = resolve(),
        smsTwoFactorService: SMSTwoFactorSettingsServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
        settingsAuthenticating: AppSettingsAuthenticating = resolve(),
        tiersProviding: TierLimitsProviding = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI,
        authenticationCoordinator: AuthenticationCoordinating,
        referralAdapter: ReferralAdapterAPI = resolve(),
        recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding = resolve(),
        blockchainDomainsAdapter: BlockchainDomainsAdapter = resolve()
    ) {
        self.smsTwoFactorService = smsTwoFactorService
        self.settingsService = settingsService
        self.tiersProviding = tiersProviding
        self.referralAdapter = referralAdapter

        self.cardSectionInteractor = CardSettingsSectionInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProvider: tiersProviding
        )

        self.bankSectionInteractor = BanksSettingsSectionInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProvider: tiersProviding
        )

        self.emailVerificationBadgeInteractor = EmailVerificationBadgeInteractor(
            service: settingsService
        )
        self.mobileVerificationBadgeInteractor = MobileVerificationBadgeInteractor(
            service: settingsService
        )
        self.twoFactorVerificationBadgeInteractor = TwoFactorVerificationBadgeInteractor(
            service: settingsService
        )
        self.preferredCurrencyBadgeInteractor = PreferredCurrencyBadgeInteractor()
        self.preferredTradingCurrencyBadgeInteractor = PreferredTradingCurrencyBadgeInteractor()

        self.biometryProviding = BiometryProvider(settings: settingsAuthenticating)
        self.blockchainDomainsAdapter = blockchainDomainsAdapter
        self.settingsAuthenticating = settingsAuthenticating
        self.recoveryPhraseStatusProvider = recoveryPhraseStatusProvider
        self.credentialsStore = credentialsStore
        self.authenticationCoordinator = authenticationCoordinator
    }

    func refresh() {
        recoveryPhraseStatusProvider.fetchTriggerSubject.send(())
        tiersProviding.fetchTriggerRelay.accept(())
        settingsService.fetch(force: true)
            .subscribe()
            .disposed(by: disposeBag)
        bankSectionInteractor.refresh()
    }
}
