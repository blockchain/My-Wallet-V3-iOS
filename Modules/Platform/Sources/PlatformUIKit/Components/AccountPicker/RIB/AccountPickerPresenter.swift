// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxSwift

public protocol AccountPickerPresentable: Presentable {

    /// An optional button that is displayed at the bottom of the
    /// account picker screen.
    var button: ButtonViewModel? { get }

    /// Connect the interactor to the presenter. Returns effects from the presentation layer.
    /// - Parameter state: The state of the interactor
    func connect(state: Driver<AccountPickerInteractor.State>) -> Driver<AccountPickerInteractor.Effects>
}

public final class AccountPickerPresenter: Presenter<AccountPickerViewControllable>, AccountPickerPresentable {

    // MARK: - Public Properties

    public let button: ButtonViewModel?

    // MARK: - Private Properties

    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel?
    private let headerModel: AccountPickerHeaderType
    private let showWithdrawalLocks: Bool
    private let showTopMovers: Bool

    // MARK: - Init

    init(
        viewController: AccountPickerViewControllable,
        action: AssetAction,
        navigationModel: ScreenNavigationModel?,
        headerModel: AccountPickerHeaderType,
        buttonViewModel: ButtonViewModel? = nil,
        showWithdrawalLocks: Bool = false,
        showTopMovers: Bool
    ) {
        self.action = action
        self.button = buttonViewModel
        self.navigationModel = navigationModel
        self.headerModel = headerModel
        self.showWithdrawalLocks = showWithdrawalLocks
        self.showTopMovers = showTopMovers
        super.init(viewController: viewController)
    }

    // MARK: - Methods

    public func connect(state: Driver<AccountPickerInteractor.State>) -> Driver<AccountPickerInteractor.Effects> {
        let sections = state.map(\.interactors)
            .map { [action] items -> [AccountPickerCellItem] in
                items.map { interactor in
                    AccountPickerCellItem(interactor: interactor, assetAction: action)
                }
            }
            .map { [action, showWithdrawalLocks, showTopMovers] items -> AccountPickerSectionViewModel in
                var itemsToReturn = items

                // we only want to show top movers if the view is presenting single accounts (like in the case of the buy flow)
                if showTopMovers && items.filter({$0.isSingleAccount}).isNotEmpty {
                    itemsToReturn = [AccountPickerCellItem(interactor: .topMovers, assetAction: action)] + items
                }

                if showWithdrawalLocks {
                    return AccountPickerSectionViewModel(
                                           items: [AccountPickerCellItem(interactor: .withdrawalLocks, assetAction: action)] + itemsToReturn
                           )
                } else {
                    return AccountPickerSectionViewModel(items: itemsToReturn)
                }
            }
            .map { [$0] }

        let headerModel = headerModel
        let navigationModel = navigationModel
        let presentableState = sections
            .map { sections -> AccountPickerPresenter.State in
                AccountPickerPresenter.State(
                    headerModel: headerModel,
                    navigationModel: navigationModel,
                    hasTopMoversSection: true,
                    sections: sections
                )
            }
        return viewController.connect(state: presentableState)
    }
}

extension AccountPickerPresenter {
    public struct State {
        public var headerModel: AccountPickerHeaderType
        public var navigationModel: ScreenNavigationModel?
        public var hasTopMoversSection: Bool
        public var sections: [AccountPickerSectionViewModel]
    }
}
