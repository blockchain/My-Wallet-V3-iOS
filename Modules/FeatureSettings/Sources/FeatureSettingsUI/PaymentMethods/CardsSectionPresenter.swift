// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardPaymentDomain
import PlatformKit
import PlatformUIKit
import RxSwift

final class CardsSectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .cards

    var state: Observable<SettingsSectionLoadingState> {
        interactor
            .state
            .map(weak: self) { (self, state) -> SettingsSectionLoadingState in
                switch state {
                case .invalid:
                    /// Do not show the `Linked Cards` section
                    return .loaded(next: .empty)
                case .calculating:
                    /// Show a loading cell should cards be enabled but we are
                    /// still waiting on CardData.
                    let cells: [SettingsCellViewModel] = [SettingsCellViewModel(cellType: .cards(.skeleton(0)))]
                    return .loaded(next: .some(.init(sectionType: .cards, items: cells)))
                case .value(let cards):
                    let presenters = Array(cards)
                    let addCardCellViewModel = SettingsCellViewModel(
                        cellType: .cards(.add(self.addPaymentMethodCellPresenter))
                    )
                    let cells = presenters.viewModels + [addCardCellViewModel]
                    let viewModel = SettingsSectionViewModel(
                        sectionType: self.sectionType,
                        items: cells
                    )

                    return .loaded(next: .some(viewModel))
                }
            }
    }

    // MARK: - Private Properties

    private let addPaymentMethodCellPresenter: AddPaymentMethodCellPresenter
    private let interactor: CardSettingsSectionInteractor

    init(interactor: CardSettingsSectionInteractor) {
        self.interactor = interactor
        self.addPaymentMethodCellPresenter = AddPaymentMethodCellPresenter(
            interactor: interactor.addPaymentMethodInteractor
        )

//        self.state =
//            interactor
//            .state
//                .map(weak: self) { (self, state) -> SettingsSectionLoadingState in
//                    switch state {
//                    case .invalid:
//                        /// Do not show the `Linked Cards` section
//                        return .loaded(next: .empty)
//                    case .calculating:
//                        /// Show a loading cell should cards be enabled but we are
//                        /// still waiting on CardData.
//                        let cells: [SettingsCellViewModel] = [SettingsCellViewModel(cellType: .cards(.skeleton(0)))]
//                        return .loaded(next: .some(.init(sectionType: .cards, items: cells)))
//                    case .value(let cards):
//                        let presenters = Array(cards)
//                        let addCardCellViewModel = SettingsCellViewModel(
//                            cellType: .cards(.add(self.addPaymentMethodCellPresenter))
//                        )
//                        let cells = presenters.viewModels + [addCardCellViewModel]
//                        let viewModel = SettingsSectionViewModel(
//                            sectionType: self.sectionType,
//                            items: cells
//                        )
//
//                        return .loaded(next: .some(viewModel))
//                    }
//                }
    }
}

extension [LinkedCardCellPresenter] {

    fileprivate var viewModels: [SettingsCellViewModel] {
        map {
            SettingsCellViewModel(cellType: .cards(.linked($0)))
        }
    }

    fileprivate init(_ cards: [CardData]) {
        self = cards.map { LinkedCardCellPresenter(acceptsUserInteraction: false, cardData: $0) }
    }
}
