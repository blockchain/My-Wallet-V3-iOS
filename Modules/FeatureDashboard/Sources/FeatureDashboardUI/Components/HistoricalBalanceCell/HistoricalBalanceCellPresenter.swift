// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class HistoricalBalanceCellPresenter {

    private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

    private let badgeImageViewModel: BadgeImageViewModel
    var thumbnail: Driver<BadgeImageViewModel> {
        .just(badgeImageViewModel)
    }

    var name: Driver<LabelContent> {
        .just(
            .init(
                text: interactor.cryptoCurrency.name,
                font: .main(.semibold, 20),
                color: .dashboardAssetTitle,
                accessibility: .id("\(AccessibilityId.titleLabelFormat)\(interactor.cryptoCurrency.name)")
            )
        )
    }

    var assetNetworkContent: Driver<LabelContent?> {
        guard let evmNetwork = interactor.evmNetwork else {
            return .just(nil)
        }
        let evmNetworkName = evmNetwork.networkConfig.shortName
        return .just(
            .init(
                text: evmNetworkName,
                font: .main(.semibold, 12),
                color: .descriptionText,
                accessibility: .id("\(AccessibilityId.titleLabelFormat)\(evmNetworkName)")
            )
        )
    }

    var displayCode: Driver<LabelContent> {
        .just(
            .init(
                text: interactor.cryptoCurrency.displayCode,
                font: .main(.medium, 14),
                color: .descriptionText,
                accessibility: .id("\(AccessibilityId.titleLabelFormat)\(interactor.cryptoCurrency.displayCode)")
            )
        )
    }

    let pricePresenter: AssetPriceViewPresenter
    let sparklinePresenter: AssetSparklinePresenter
    let balancePresenter: AssetBalanceViewPresenter

    var cryptoCurrency: CryptoCurrency {
        interactor.cryptoCurrency
    }

    private let interactor: HistoricalBalanceCellInteractor

    init(
        interactor: HistoricalBalanceCellInteractor,
        appMode: AppMode
    ) {
        self.interactor = interactor
        self.sparklinePresenter = AssetSparklinePresenter(
            with: interactor.sparklineInteractor
        )
        self.pricePresenter = AssetPriceViewPresenter(
            interactor: interactor.priceInteractor,
            descriptors: .assetPrice(accessibilityIdSuffix: interactor.cryptoCurrency.displayCode)
        )
        self.balancePresenter = AssetBalanceViewPresenter(
            alignment: appMode == .pkw ? .trailing : .leading,
            interactor: interactor.balanceInteractor,
            descriptors: .default(
                cryptoAccessiblitySuffix: AccessibilityId.cryptoBalanceLabelFormat,
                fiatAccessiblitySuffix: AccessibilityId.fiatBalanceLabelFormat
            )
        )

        let theme = BadgeImageViewModel.Theme(
            backgroundColor: .background,
            cornerRadius: .round,
            imageViewContent: ImageViewContent(
                imageResource: interactor.cryptoCurrency.logoResource,
                accessibility: .id("\(AccessibilityId.assetImageView)\(interactor.cryptoCurrency.displayCode)"),
                renderingMode: .normal
            ),
            marginOffset: 0
        )
        self.badgeImageViewModel = BadgeImageViewModel(theme: theme)
    }
}
