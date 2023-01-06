// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class SettingsScreenPresenter {

    // MARK: - Types

    typealias Section = SettingsSectionType

    // MARK: - Navigation Properties

    let trailingButton: Screen.Style.TrailingButton = .none

    var leadingButton: Screen.Style.LeadingButton {
        .none
    }

    let barStyle: Screen.Style.Bar = .lightContent()

    // MARK: - Properties

    var sectionObservable: Observable<[SettingsSectionViewModel]> {
        sectionsProvider.sections
    }

    var sectionArrangement: [Section] {
        sectionRelay.value
    }

    // MARK: - Cell Presenters

    let sectionsProvider: SettingsSectionsProvider

    // MARK: - Public

    let actionRelay = PublishRelay<SettingsScreenAction>()

    // MARK: Private Properties

    private unowned let router: SettingsRouterAPI
    private let sectionRelay = BehaviorRelay<[Section]>(value: Section.default)
    private let interactor: SettingsScreenInteractor
    private let disposeBag = DisposeBag()

    // MARK: - Section Presenters

    private let profileSectionPresenter: ProfileSectionPresenter
    private let preferencesSectionPresenter: PreferencesSectionPresenter
    private let connectPresenter: ConnectSectionPresenter
    private let securitySectionPresenter: SecuritySectionPresenter
    private let banksSectionPresenter: BanksSectionPresenter
    private let cardsSectionPresenter: CardsSectionPresenter
    private let helpSectionPresenter: HelpSectionPresenter
    private let referralSectionPresenter: ReferralSectionPresenter

    // MARK: - Init

    init(
        interactor: SettingsScreenInteractor,
        router: SettingsRouterAPI
    ) {
        self.helpSectionPresenter = HelpSectionPresenter()

        self.connectPresenter = ConnectSectionPresenter()

        self.securitySectionPresenter = .init(
            smsTwoFactorService: interactor.smsTwoFactorService,
            credentialsStore: interactor.credentialsStore,
            biometryProvider: interactor.biometryProviding,
            settingsAuthenticater: interactor.settingsAuthenticating,
            recoveryPhraseStatusProvider: interactor.recoveryPhraseStatusProvider,
            authenticationCoordinator: interactor.authenticationCoordinator
        )

        self.cardsSectionPresenter = CardsSectionPresenter(
            interactor: interactor.cardSectionInteractor
        )

        self.banksSectionPresenter = BanksSectionPresenter(
            interactor: interactor.bankSectionInteractor
        )

        self.profileSectionPresenter = ProfileSectionPresenter(
            tiersLimitsProvider: interactor.tiersProviding,
            emailVerificationInteractor: interactor.emailVerificationBadgeInteractor,
            mobileVerificationInteractor: interactor.mobileVerificationBadgeInteractor,
            blockchainDomainsAdapter: interactor.blockchainDomainsAdapter
        )

        self.preferencesSectionPresenter = .init(
            preferredCurrencyBadgeInteractor: interactor.preferredCurrencyBadgeInteractor,
            preferredTradingCurrencyBadgeInteractor: interactor.preferredTradingCurrencyBadgeInteractor
        )

        self.referralSectionPresenter = ReferralSectionPresenter(refferalAdapter: interactor.referralAdapter)

        self.sectionsProvider = SettingsSectionsProvider(
            about: helpSectionPresenter,
            connect: connectPresenter,
            banks: banksSectionPresenter,
            cards: cardsSectionPresenter,
            security: securitySectionPresenter,
            profile: profileSectionPresenter,
            preferences: preferencesSectionPresenter,
            referral: referralSectionPresenter
        )

        self.router = router
        self.interactor = interactor

        setup()
    }

    // MARK: - Private

    private func setup() {
        actionRelay
            .bindAndCatch(to: router.actionRelay)
            .disposed(by: disposeBag)

        sectionsProvider
            .sections
            .observe(on: MainScheduler.instance)
            .map { $0.map(\.sectionType) }
            .bindAndCatch(to: sectionRelay)
            .disposed(by: disposeBag)
    }

    // MARK: - Public

    /// Should be called each time the `Settings` screen comes into view
    func refresh() {
        interactor.refresh()
    }

    // MARK: - Exposed

    func navigationBarLeadingButtonTapped() {
        router.previousRelay.accept(())
    }
}
