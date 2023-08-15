// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureProductsDomain
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift

final class ConnectSectionPresenter: SettingsSectionPresenting {

    typealias State = SettingsSectionLoadingState

    let sectionType: SettingsSectionType = .connect
    var state: Observable<State>
    var app: AppProtocol

    init(
        app: AppProtocol
    ) {
        self.app = app
        let presenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.ExchangeConnect.title),
            interactor: DefaultBadgeAssetInteractor(initialState: .loaded(next: .launch)),
            title: LocalizationConstants.Settings.Badge.blockchainExchange
        )
        let state = State.loaded(next:
            .some(
                .init(
                    sectionType: sectionType,
                    items: [.init(cellType: .badge(.pitConnection, presenter))]
                )
            )
        )

        let externalBrokerageActivePublisher = app.publisher(for: blockchain.api.nabu.gateway.products[ProductIdentifier.useExternalTradingAccount].is.eligible, as: Bool.self)
            .replaceError(with: false)
            .eraseToAnyPublisher()

        self.state = externalBrokerageActivePublisher
            .map {
                externalBrokerageActive in
                guard externalBrokerageActive == false else {
                    return .loaded(next: .empty)
                }
                return state
              }
        .asObservable()
    }
}
