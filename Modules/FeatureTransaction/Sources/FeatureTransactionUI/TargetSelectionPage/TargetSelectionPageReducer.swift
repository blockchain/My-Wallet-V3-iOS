// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
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
    func presentableState(
        for interactorState: Driver<TargetSelectionPageInteractor.State>
    ) -> Driver<TargetSelectionPagePresenter.State>
}

final class TargetSelectionPageReducer: TargetSelectionPageReducerAPI {

    // MARK: - Types

    private enum Constant {
        static let sendToDomainAnnouncementViewed = "sendToDomainAnnouncementViewed"
    }

    private typealias LocalizationIds = LocalizationConstants.Transaction.TargetSource

    // MARK: - Private Properties

    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let cacheSuite: CacheSuite
    private let didCloseSendToDomainsAnnouncement = CurrentValueSubject<Void, Never>(())

    private var shouldShowSendToDomainsAnnouncement: AnyPublisher<Bool, Never> {
        didCloseSendToDomainsAnnouncement
            .eraseToAnyPublisher()
            .flatMap { [cacheSuite, featureFlagsService] _ -> AnyPublisher<Bool, Never> in
                guard !cacheSuite.bool(forKey: Constant.sendToDomainAnnouncementViewed) else {
                    return .just(false)
                }
                return featureFlagsService.isEnabled(.sendToDomainsAnnouncement)
            }
            .eraseToAnyPublisher()
    }

    init(
        action: AssetAction,
        navigationModel: ScreenNavigationModel,
        cacheSuite: CacheSuite,
        featureFlagsService: FeatureFlagsServiceAPI
    ) {
        self.action = action
        self.navigationModel = navigationModel
        self.featureFlagsService = featureFlagsService
        self.cacheSuite = cacheSuite
    }

    func presentableState(
        for interactorState: Driver<TargetSelectionPageInteractor.State>
    ) -> Driver<TargetSelectionPagePresenter.State> {
        let action = action
        let sourceSection = interactorState
            .compactMap(\.sourceInteractor)
            .map { [$0] }
            .map { items -> [TargetSelectionPageCellItem] in
                items.map { interactor in
                    TargetSelectionPageCellItem(interactor: interactor, assetAction: action)
                }
            }
            .flatMap { [weak self] items -> Driver<TargetSelectionPageSectionModel> in
                guard let self else { return .empty() }
                return .just(.source(header: self.provideSourceSectionHeader(for: action), items: items))
            }

        let sourceAccountStrategy = interactorState
            .compactMap(\.sourceInteractor)
            .map(\.account)
            .map { account -> TargetDestinationsStrategyAPI in
                AnySourceDestinationStrategy(sourceAccount: account)
            }
            .map(TargetDestinationSections.init(strategy:))

        let destinationSections = interactorState
            .map(\.destinationInteractors)
            .withLatestFrom(sourceAccountStrategy) { ($0, $1) }
            .map { items, strategy -> [TargetSelectionPageSectionModel] in
                strategy.sections(interactors: items, action: action)
            }

        let cacheSuite = cacheSuite
        let didCloseSendToDomainsAnnouncement = didCloseSendToDomainsAnnouncement
        let inputFieldSection = Driver
            .combineLatest(
                interactorState
                    .map(\.inputFieldInteractor)
                    .distinctUntilChanged(),
                shouldShowSendToDomainsAnnouncement
                    .asObservable()
                    .asDriver(onErrorJustReturn: false)
            )
            .map { item, sendToDomainsAnnouncement -> [TargetSelectionPageSectionModel] in
                guard let item else {
                    return []
                }
                let header = TargetSelectionHeaderBuilder(
                    headerType: .section(.init(sectionTitle: LocalizationConstants.Transaction.to))
                )
                var items = [
                    TargetSelectionPageCellItem(interactor: item, assetAction: action)
                ]
                if sendToDomainsAnnouncement {
                    items.append(TargetSelectionPageCellItem(
                        cardView: .sendToDomains(
                            didClose: {
                                cacheSuite.set(true, forKey: Constant.sendToDomainAnnouncementViewed)
                                didCloseSendToDomainsAnnouncement.send(())
                            }
                        )
                    ))
                }
                let section = TargetSelectionPageSectionModel.destination(
                    header: header,
                    items: items
                )
                return [section]
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
            .combineLatest(sourceSection, inputFieldSection, destinationSections)
            .map { [$0] + $1 + $2 }

        let navigationModel = navigationModel
        return Driver.combineLatest(sections, button)
            .map { values -> TargetSelectionPagePresenter.State in
                let (sections, button) = values
                return .init(
                    actionButtonModel: button,
                    navigationModel: navigationModel,
                    sections: sections
                )
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
        case .send,
             .withdraw,
             .interestWithdraw:
            return TargetSelectionHeaderBuilder(
                headerType: .section(
                    .init(
                        sectionTitle: LocalizationConstants.Transaction.from
                    )
                )
            )
        case .sign,
             .deposit,
             .interestTransfer,
             .stakingDeposit,
             .receive,
             .buy,
             .sell,
             .viewActivity,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            unimplemented()
        }
    }
}
