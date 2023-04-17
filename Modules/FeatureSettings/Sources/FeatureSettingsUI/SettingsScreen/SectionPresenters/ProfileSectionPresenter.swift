// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
import Combine
import DIKit
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
        app: AppProtocol = resolve(),
        tiersLimitsProvider: TierLimitsProviding,
        emailVerificationInteractor: EmailVerificationBadgeInteractor,
        mobileVerificationInteractor: MobileVerificationBadgeInteractor,
        blockchainDomainsAdapter: BlockchainDomainsAdapter
    ) {
        let limitsPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.AccountLimits.title),
            interactor: TierLimitsBadgeInteractor(limitsProviding: tiersLimitsProvider),
            title: LocalizationConstants.KYC.accountLimits
        )
        self.limitsPresenter = limitsPresenter
        let emailVerificationPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Email.title),
            interactor: emailVerificationInteractor,
            title: LocalizationConstants.Settings.Badge.email
        )
        self.emailVerificationPresenter = emailVerificationPresenter
        let mobileVerificationPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Mobile.title),
            interactor: mobileVerificationInteractor,
            title: LocalizationConstants.Settings.Badge.mobileNumber
        )
        self.mobileVerificationPresenter = mobileVerificationPresenter
        let blockchainDomainsPresenter = BlockchainDomainsCommonCellPresenter(provider: blockchainDomainsAdapter)

        self.state = app.publisher(for: blockchain.api.nabu.gateway.products["KYC_VERIFICATION"].is.eligible, as: Bool.self)
            .replaceError(with: true)
            .map { isEligible -> SettingsSectionLoadingState in
                if isEligible {
                    return .loaded(
                        next: .some(
                            SettingsSectionViewModel(
                                sectionType: .profile,
                                items: [
                                    .init(cellType: .badge(.limits, limitsPresenter)),
                                    .init(cellType: .clipboard(.walletID)),
                                    .init(cellType: .badge(.emailVerification, emailVerificationPresenter)),
                                    .init(cellType: .badge(.mobileVerification, mobileVerificationPresenter)),
                                    .init(cellType: .common(.blockchainDomains, blockchainDomainsPresenter)),
                                    .init(cellType: .common(.webLogin))
                                ]
                            )
                        )
                    )
                } else {
                    return .loaded(
                        next: .some(
                            SettingsSectionViewModel(
                                sectionType: .profile,
                                items: [
                                    .init(cellType: .clipboard(.walletID)),
                                    .init(cellType: .badge(.emailVerification, emailVerificationPresenter)),
                                    .init(cellType: .badge(.mobileVerification, mobileVerificationPresenter)),
                                    .init(cellType: .common(.blockchainDomains, blockchainDomainsPresenter)),
                                    .init(cellType: .common(.webLogin))
                                ]
                            )
                        )
                    )
                }
            }
            .asObservable()
    }
}
