// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

// MARK: - Builder

typealias BackButtonInterceptor = () -> Observable<
    (
        step: TransactionFlowStep,
        backStack: [TransactionFlowStep],
        isGoingBack: Bool
    )
>

protocol TargetSelectionBuildable {
    func build(
        listener: TargetSelectionPageListener,
        navigationModel: ScreenNavigationModel,
        backButtonInterceptor: @escaping BackButtonInterceptor
    ) -> TargetSelectionPageRouting
}

final class TargetSelectionPageBuilder: TargetSelectionBuildable {

    // MARK: - Private Properties

    private let accountProvider: SourceAndTargetAccountProviding
    private let cacheSuite: CacheSuite

    // MARK: - Init

    init(
        accountProvider: SourceAndTargetAccountProviding,
        cacheSuite: CacheSuite
    ) {
        self.accountProvider = accountProvider
        self.cacheSuite = cacheSuite
    }

    // MARK: - Public Methods

    func build(
        listener: TargetSelectionPageListener,
        navigationModel: ScreenNavigationModel,
        backButtonInterceptor: @escaping BackButtonInterceptor
    ) -> TargetSelectionPageRouting {
        let viewController = TargetSelectionViewController()
        let reducer = TargetSelectionPageReducer(
            navigationModel: navigationModel,
            cacheSuite: cacheSuite
        )
        let presenter = TargetSelectionPagePresenter(
            viewController: viewController,
            selectionPageReducer: reducer
        )
        let radioSelectionHandler = RadioSelectionHandler()
        let interactor = TargetSelectionPageInteractor(
            targetSelectionPageModel: .init(interactor: TargetSelectionInteractor()),
            presenter: presenter,
            accountProvider: accountProvider,
            listener: listener,
            radioSelectionHandler: radioSelectionHandler,
            backButtonInterceptor: backButtonInterceptor
        )
        return TargetSelectionPageRouter(interactor: interactor, viewController: viewController)
    }
}
