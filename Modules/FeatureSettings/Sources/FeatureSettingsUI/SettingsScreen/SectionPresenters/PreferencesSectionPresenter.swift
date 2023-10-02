// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureProductsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class PreferencesSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let app: AppProtocol

    lazy var sectionType: SettingsSectionType = .preferences

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
        let preferredCurrencyCellPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Currency.title),
            interactor: preferredCurrencyBadgeInteractor,
            title: LocalizationConstants.Settings.Badge.walletDisplayCurrency
        )

        self.preferredCurrencyCellPresenter = preferredCurrencyCellPresenter

        let preferredTradingCurrencyCellPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Currency.title),
            interactor: preferredTradingCurrencyBadgeInteractor,
            title: LocalizationConstants.Settings.Badge.tradingCurrency
        )
        self.preferredTradingCurrencyCellPresenter = preferredTradingCurrencyCellPresenter

        let themePresenter = ThemeCommonCellPresenter(app: app)
        self.themePresenter = themePresenter
        let externalBrokerageActivePublisher = app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
            .replaceError(with: false)
            .eraseToAnyPublisher()

        self.state = externalBrokerageActivePublisher
            .map { externalBrokerageActive in
                let items: [SettingsCellViewModel] = [
                    externalBrokerageActive ? nil : .init(cellType: .badge(.currencyPreference, preferredCurrencyCellPresenter)),
                    externalBrokerageActive ? nil : .init(cellType: .badge(.tradingCurrencyPreference, preferredTradingCurrencyCellPresenter)),
                    .init(cellType: .common(.theme, themePresenter)),
                    .init(cellType: .common(.notifications))
                ]
                    .compactMap { $0 }

                let viewModel = SettingsSectionViewModel(
                    sectionType: .preferences,
                    items: items
                )

                return .loaded(next: .some(viewModel))
            }
            .asObservable()
    }
}
