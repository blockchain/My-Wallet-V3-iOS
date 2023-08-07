// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import WalletPayloadKit

final class SecuritySectionPresenter: SettingsSectionPresenting {

    let sectionType: SettingsSectionType = .security

    var state: Observable<SettingsSectionLoadingState>

    private let recoveryCellPresenter: BadgeCellPresenting
    private let bioAuthenticationCellPresenter: BioAuthenticationSwitchCellPresenter
    private let smsTwoFactorSwitchCellPresenter: SMSTwoFactorSwitchCellPresenter
    private let cloudBackupSwitchCellPresenter: CloudBackupSwitchCellPresenter

    init(
        smsTwoFactorService: SMSTwoFactorSettingsServiceAPI,
        credentialsStore: CredentialsStoreAPI,
        biometryProvider: BiometryProviding,
        settingsAuthenticater: AppSettingsAuthenticating,
        recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding,
        authenticationCoordinator: AuthenticationCoordinating,
        tiersLimitsProvider: TierLimitsProviding,
        cloudSettings: CloudBackupConfiguring = resolve()
    ) {
        let smsTwoFactorSwitchCellPresenter = SMSTwoFactorSwitchCellPresenter(
            service: smsTwoFactorService
        )
        self.smsTwoFactorSwitchCellPresenter = smsTwoFactorSwitchCellPresenter
        let bioAuthenticationCellPresenter = BioAuthenticationSwitchCellPresenter(
            biometryProviding: biometryProvider,
            appSettingsAuthenticating: settingsAuthenticater,
            authenticationCoordinator: authenticationCoordinator
        )
        self.bioAuthenticationCellPresenter = bioAuthenticationCellPresenter
        let recoveryCellPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.BackupPhrase.title),
            interactor: RecoveryPhraseBadgeInteractor(provider: recoveryPhraseStatusProvider),
            title: LocalizationConstants.Settings.Badge.recoveryPhrase
        )
        self.recoveryCellPresenter = recoveryCellPresenter
        let cloudBackupSwitchCellPresenter = CloudBackupSwitchCellPresenter(
            cloudSettings: cloudSettings,
            credentialsStore: credentialsStore
        )
        self.cloudBackupSwitchCellPresenter = cloudBackupSwitchCellPresenter

        self.state = tiersLimitsProvider.tiers
            .map(\.isVerifiedApproved)
            .catchAndReturn(false)
            .map { verified -> SettingsSectionLoadingState in
                if verified {
                    return .loaded(
                        next: .some(
                            SettingsSectionViewModel(
                                sectionType: .security,
                                items: [
                                    .init(cellType: .switch(.sms2FA, smsTwoFactorSwitchCellPresenter)),
                                    .init(cellType: .switch(.cloudBackup, cloudBackupSwitchCellPresenter)),
                                    .init(cellType: .common(.changePassword)),
                                    .init(cellType: .badge(.recoveryPhrase, recoveryCellPresenter)),
                                    .init(cellType: .common(.changePIN)),
                                    .init(cellType: .switch(.bioAuthentication, bioAuthenticationCellPresenter)),
                                    .init(cellType: .common(.userDeletion))
                                ]
                            )
                        )
                    )
                } else {
                    return .loaded(
                        next: .some(
                            SettingsSectionViewModel(
                                sectionType: .security,
                                items: [
                                    .init(cellType: .switch(.cloudBackup, cloudBackupSwitchCellPresenter)),
                                    .init(cellType: .common(.changePassword)),
                                    .init(cellType: .badge(.recoveryPhrase, recoveryCellPresenter)),
                                    .init(cellType: .common(.changePIN)),
                                    .init(cellType: .switch(.bioAuthentication, bioAuthenticationCellPresenter)),
                                    .init(cellType: .common(.userDeletion))
                                ]
                            )
                        )
                    )
                }
            }
    }
}
