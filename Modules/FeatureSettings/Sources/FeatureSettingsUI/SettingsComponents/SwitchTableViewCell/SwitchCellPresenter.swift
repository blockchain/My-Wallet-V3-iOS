// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import DIKit
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

protocol SwitchCellPresenting {
    var accessibility: Accessibility { get }
    var labelContentPresenting: LabelContentPresenting { get }
    var switchViewPresenting: SwitchViewPresenting { get }
}

class CloudBackupSwitchCellPresenter: SwitchCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell.CloudBackup
    private typealias LocalizedString = LocalizationConstants.Settings

    let accessibility: Accessibility = .id(AccessibilityId.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting

    init(cloudSettings: CloudBackupConfiguring, credentialsStore: CredentialsStoreAPI) {
        self.labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.cloudBackup,
            descriptors: .settings
        )
        self.switchViewPresenting = CloudBackupSwitchViewPresenter(
            cloudSettings: cloudSettings,
            credentialsStore: credentialsStore
        )
    }
}

class SMSTwoFactorSwitchCellPresenter: SwitchCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell

    let accessibility: Accessibility = .id(AccessibilityId.TwoStepVerification.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting

    init(service: SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI) {
        self.labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.twoFactorAuthentication,
            descriptors: .settings
        )
        self.switchViewPresenting = SMSSwitchViewPresenter(service: service)
    }
}

class BioAuthenticationSwitchCellPresenter: SwitchCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell

    let accessibility: Accessibility = .id(AccessibilityId.BioAuthentication.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting

    init(
        biometryProviding: BiometryProviding,
        appSettingsAuthenticating: AppSettingsAuthenticating,
        authenticationCoordinator: AuthenticationCoordinating
    ) {
        self.labelContentPresenting = BiometryLabelContentPresenter(
            provider: biometryProviding,
            descriptors: .settings
        )
        self.switchViewPresenting = BiometrySwitchViewPresenter(
            provider: biometryProviding,
            settingsAuthenticating: appSettingsAuthenticating,
            authenticationCoordinator: authenticationCoordinator
        )
    }
}

class SmallBalancesSwitchCellPresenter: SwitchCellPresenting {

    private typealias A18y = Accessibility.Identifier.Settings.SettingsCell.SmallBalance

    let accessibility: Accessibility = .id(A18y.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting

    init() {
        self.labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.smallBalances,
            descriptors: .settings
        )
        self.switchViewPresenting = SmallBalancesSwitchViewPresenter()
    }
}

class SmallBalancesSwitchViewPresenter: SwitchViewPresenting {

    private typealias A18y = Accessibility.Identifier.Settings.SettingsCell.SmallBalance

    var viewModel: SwitchViewModel
    var bag: Set<AnyCancellable> = .init()

    init(app: AppProtocol = resolve()) {

        self.viewModel = SwitchViewModel(
            accessibility: .id(A18y.title),
            isOn: app.state.yes(if: blockchain.ux.user.account.preferences.small.balances.are.hidden)
        )

        app.publisher(for: blockchain.ux.user.account.preferences.small.balances.are.hidden, as: Bool.self)
            .replaceError(with: false)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: viewModel.isSwitchedOnRelay.accept)
            .store(in: &bag)

        viewModel.isSwitchedOnRelay.publisher.sink { isOn in
            app.state.set(blockchain.ux.user.account.preferences.small.balances.are.hidden, to: isOn)
        }
        .store(in: &bag)
    }
}
