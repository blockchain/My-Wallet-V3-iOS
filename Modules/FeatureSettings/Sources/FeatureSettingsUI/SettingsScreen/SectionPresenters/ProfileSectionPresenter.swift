// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class ProfileSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let sectionType: SettingsSectionType = .profile
    var state: Observable<SettingsSectionLoadingState>

    private let limitsPresenter: BadgeCellPresenting
    private let emailVerificationPresenter: BadgeCellPresenting
    private let mobileVerificationPresenter: BadgeCellPresenting

    init(
        tiersLimitsProvider: TierLimitsProviding,
        emailVerificationInteractor: EmailVerificationBadgeInteractor,
        mobileVerificationInteractor: MobileVerificationBadgeInteractor,
        blockchainDomainsAdapter: BlockchainDomainsAdapter
    ) {
        self.limitsPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.AccountLimits.title),
            interactor: TierLimitsBadgeInteractor(limitsProviding: tiersLimitsProvider),
            title: LocalizationConstants.KYC.accountLimits
        )
        self.emailVerificationPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Email.title),
            interactor: emailVerificationInteractor,
            title: LocalizationConstants.Settings.Badge.email
        )
        self.mobileVerificationPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Mobile.title),
            interactor: mobileVerificationInteractor,
            title: LocalizationConstants.Settings.Badge.mobileNumber
        )

        let blockchainDomainsPresenter = BlockchainDomainsCommonCellPresenter(provider: blockchainDomainsAdapter)

        let items: [SettingsCellViewModel] = [
            .init(cellType: .badge(.limits, limitsPresenter)),
            .init(cellType: .clipboard(.walletID)),
            .init(cellType: .badge(.emailVerification, emailVerificationPresenter)),
            .init(cellType: .badge(.mobileVerification, mobileVerificationPresenter)),
            .init(cellType: .common(.blockchainDomains, blockchainDomainsPresenter)),
            .init(cellType: .common(.webLogin))
        ]

        var viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: items
        )

        self.state = .just(.loaded(next: .some(viewModel)))
    }
}
