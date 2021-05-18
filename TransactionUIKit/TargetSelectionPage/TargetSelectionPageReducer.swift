//
//  TargetSelectoionPageReducer.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Types adopting this should be able to provide a stream of presentable state of type `TargetSelectionPagePresenter.State` which is used by `TargetSelectionPagePresentable` that presents the neccessary sections define in the state.
protocol TargetSelectionPageReducerAPI {
    /// Provides a stream of `TargetSelectionPagePresenter.State` from the given `TargetSelectionPageInteractor.State`
    /// - Parameter interactorState: A stream of `TargetSelectionPageInteractor.State` as defined by `TargetSelectionPageInteractor`
    func presentableState(for interactorState: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPagePresenter.State>
}

final class TargetSelectionPageReducer: TargetSelectionPageReducerAPI {

    private typealias LocalizationIds = LocalizationConstants.Transaction.TargetSource
    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel

    init(action: AssetAction,
         navigationModel: ScreenNavigationModel) {
        self.action = action
        self.navigationModel = navigationModel
    }

    func presentableState(for interactorState: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPagePresenter.State> {
        let action = self.action
        let sourceSection = interactorState
            .map(\.interactors)
            .compactMap(\.sourceInteractor)
            .map { [$0] }
            .map { items -> [TargetSelectionPageCellItem] in
                items.map { interactor in
                    TargetSelectionPageCellItem(interactor: interactor, assetAction: action)
                }
            }
            .flatMap { [weak self] items -> Driver<TargetSelectionPageSectionModel> in
                guard let self = self else { return .empty() }
                return .just(.source(header: self.provideSourceSectionHeader(for: action), items: items))
            }
        
        let sourceAccountStrategy = interactorState
            .map(\.interactors)
            .compactMap(\.sourceInteractor)
            .map(\.account)
            .map { account -> TargetDestinationsStrategyAPI in
                if account is TradingAccount {
                    return TradingSourceDestinationStrategy(sourceAccount: account)
                } else {
                    return NonTradingSourceDestinationStrategy(sourceAccount: account)
                }
            }
            .map(TargetDestinationSections.init(strategy:))

        let destinationSections = interactorState
            .map(\.interactors)
            .map(\.destinationInteractors)
            .withLatestFrom(sourceAccountStrategy) { ($0, $1) }
            .map { (items, strategy) -> [TargetSelectionPageSectionModel] in
                strategy.sections(interactors: items, action: action)
            }
        
        let button = interactorState
            .map(\.actionButtonEnabled)
            .map { canContinue -> ButtonViewModel in
                let viewModel: ButtonViewModel = .primary(with: LocalizationConstants.Transaction.next)
                viewModel.isEnabledRelay.accept(canContinue)
                return viewModel
            }
            .asDriver()
        
        let sections = Driver
            .combineLatest(sourceSection, destinationSections)
            .map { [$0] + $1 }

        let navigationModel = self.navigationModel
        return Driver.combineLatest(sections, button)
            .map { (values) -> TargetSelectionPagePresenter.State in
                let (sections, button) = values
                return .init(actionButtonModel: button, navigationModel: navigationModel, sections: sections)
            }
    }

    // MARK: - Static methods

    private func provideSourceSectionHeader(for action: AssetAction) -> TargetSelectionHeaderBuilder {
        switch action {
        case .swap:
            return TargetSelectionHeaderBuilder(
                headerType: .titledSection(
                    .init(
                        title: LocalizationConstants.Transaction.Swap.newSwapDisclaimer,
                        sectionTitle: LocalizationConstants.Transaction.Swap.swap
                    )
                )
            )
        case .send:
            return TargetSelectionHeaderBuilder(
                headerType: .section(
                    .init(
                        sectionTitle: LocalizationConstants.Transaction.from
                    )
                )
            )
        case .deposit,
             .receive,
             .sell,
             .viewActivity,
             .withdraw:
            unimplemented()
        }
    }
}
