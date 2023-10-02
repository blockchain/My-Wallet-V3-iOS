// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
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

    private let navigationModel: ScreenNavigationModel
    private let cacheSuite: CacheSuite
    private let didCloseSendToDomainsAnnouncement = CurrentValueSubject<Void, Never>(())

    private var shouldShowSendToDomainsAnnouncement: AnyPublisher<Bool, Never> {
        didCloseSendToDomainsAnnouncement
            .map { [cacheSuite] _ in
                cacheSuite.bool(forKey: Constant.sendToDomainAnnouncementViewed).isNo
            }
            .eraseToAnyPublisher()
    }

    init(
        navigationModel: ScreenNavigationModel,
        cacheSuite: CacheSuite
    ) {
        self.navigationModel = navigationModel
        self.cacheSuite = cacheSuite
    }

    func presentableState(
        for interactorState: Driver<TargetSelectionPageInteractor.State>
    ) -> Driver<TargetSelectionPagePresenter.State> {
        let sourceSection = interactorState
            .compactMap(\.sourceInteractor)
            .map { [$0] }
            .map { items -> [TargetSelectionPageCellItem] in
                items.map { interactor in
                    TargetSelectionPageCellItem(interactor: interactor)
                }
            }
            .map { items -> TargetSelectionPageSectionModel in
                TargetSelectionPageSectionModel(
                    identity: .source,
                    header: .section(LocalizationConstants.Transaction.from),
                    items: items
                )
            }
            .asDriver()

        let destinationSections = interactorState
            .map(\.destinationInteractors)
            .map { items -> [TargetSelectionPageSectionModel] in
                targetDestinationsStrategy(interactors: items)
            }

        let cacheSuite = cacheSuite
        let didCloseSendToDomainsAnnouncement = didCloseSendToDomainsAnnouncement
        let inputFieldSection = Driver
            .combineLatest(
                interactorState
                    .map(\.inputFieldInteractor)
                    .distinctUntilChanged(),
                interactorState
                    .map(\.memoFieldInteractor)
                    .distinctUntilChanged(),
                shouldShowSendToDomainsAnnouncement
                    .asObservable()
                    .asDriver(onErrorJustReturn: false)
            )
            .map { inputField, memoField, showAnnouncement -> [TargetSelectionPageSectionModel] in
                var sections: [TargetSelectionPageSectionModel] = []
                if let inputField {
                    sections.append(TargetSelectionPageSectionModel(
                        identity: .inputField,
                        header: .section(LocalizationConstants.Transaction.to),
                        items: [TargetSelectionPageCellItem(interactor: inputField)]
                    ))
                }
                if let memoField {
                    sections.append(TargetSelectionPageSectionModel(
                        identity: .memoField,
                        header: .section(LocalizationConstants.Transaction.memo),
                        items: [TargetSelectionPageCellItem(interactor: memoField)]
                    ))
                }
                if sections.isNotEmpty, showAnnouncement {
                    let card: TargetSelectionPageCellItem = .init(cardView:
                            .sendToDomains(
                                didClose: {
                                    cacheSuite.set(true, forKey: Constant.sendToDomainAnnouncementViewed)
                                    didCloseSendToDomainsAnnouncement.send(())
                                }
                            )
                    )
                    sections.append(TargetSelectionPageSectionModel(
                        identity: .card,
                        header: .none,
                        items: [card]
                    ))
                }
                return sections
            }

        let button = interactorState
            .map(\.actionButtonEnabled)
            .map { canContinue -> ButtonViewModel in
                let viewModel: ButtonViewModel = .transactionPrimary(
                    with: LocalizationConstants.Transaction.next
                )
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
}

private func targetDestinationsStrategy(
    interactors: [TargetSelectionPageCellItem.Interactor]
) -> [TargetSelectionPageSectionModel] {
    let items = interactors
        .filter(\.isInputField.isNo)
        .map { value in
            TargetSelectionPageCellItem(interactor: value)
        }
    guard items.isEmpty.isNo else {
        return []
    }
    return [
        TargetSelectionPageSectionModel(
            identity: .accounts,
            header: .section(LocalizationConstants.Transaction.accountsAndWallets),
            items: items
        )
    ]
}
