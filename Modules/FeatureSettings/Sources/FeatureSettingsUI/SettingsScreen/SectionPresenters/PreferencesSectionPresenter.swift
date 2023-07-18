// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class PreferencesSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let app: AppProtocol

    let sectionType: SettingsSectionType = .preferences

    var state: Observable<SettingsSectionLoadingState>

    private let preferredCurrencyCellPresenter: BadgeCellPresenting
    private let preferredTradingCurrencyCellPresenter: BadgeCellPresenting

    private let themePresenter: ThemeCommonCellPresenter

    init(
        app: AppProtocol,
        preferredCurrencyBadgeInteractor: PreferredCurrencyBadgeInteractor,
        preferredTradingCurrencyBadgeInteractor: PreferredTradingCurrencyBadgeInteractor
    ) {
        self.app = app
        self.preferredCurrencyCellPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Currency.title),
            interactor: preferredCurrencyBadgeInteractor,
            title: LocalizationConstants.Settings.Badge.walletDisplayCurrency
        )
        self.preferredTradingCurrencyCellPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Currency.title),
            interactor: preferredTradingCurrencyBadgeInteractor,
            title: LocalizationConstants.Settings.Badge.tradingCurrency
        )

        self.themePresenter = ThemeCommonCellPresenter(app: app)

        let items: [SettingsCellViewModel] = [
            .init(cellType: .badge(.currencyPreference, preferredCurrencyCellPresenter)),
            .init(cellType: .badge(.tradingCurrencyPreference, preferredTradingCurrencyCellPresenter)),
            .init(cellType: .common(.theme, themePresenter)),
            .init(cellType: .common(.notifications))
        ]
        let viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: items
        )

        self.state = .just(.loaded(next: .some(viewModel)))
    }
}
