// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

final class ActivityScreenPresenter {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.Activity
    private typealias LocalizedString = LocalizationConstants.Activity.MainScreen

    // MARK: - Public Properties

    /// The screen title
    let title = LocalizedString.title

    /// The `SelectionButtonView`
    let selectionButtonViewModel: SelectionButtonViewModel

    /// The title of the empty state
    var emptyActivityTitle: LabelContent {
        .init(text: LocalizedString.Empty.title,
              font: .main(.semibold, 20.0),
              color: .titleText,
              alignment: .center,
              accessibility: .none)
    }

    /// The subtitle of the empty state
    var emptyActivitySubtitle: LabelContent {
        .init(text: LocalizedString.Empty.subtitle,
              font: .main(.medium, 14.0),
              color: .descriptionText,
              alignment: .center,
              accessibility: .none)
    }

    /// The visibility state of the subviews that should be
    /// visible when there are no activity events for the
    /// selected wallet
    var emptySubviewsVisibility: Driver<Visibility> {
        interactor
            .isEmpty
            .map { $0 ? .visible : .hidden }
            .asDriver(onErrorJustReturn: .hidden)
    }

    /// All the sections that should be displayed in the
    /// Activity screen
    var sectionsObservable: Observable<[ActivityItemsSectionViewModel]> {
        activityItemsObservable
    }

    // MARK: - Private Properties (Rx)

    /// Observable of the `ActivityItemsSectionViewModel` section
    private var activityItemsObservable: Observable<[ActivityItemsSectionViewModel]> {
        interactor
            .state
            .map { (state) -> [ActivityCellItem] in
                switch state {
                case .calculating:
                    let items = Array(1...20)
                    return items.map { .skeleton($0) }
                case .invalid:
                    return []
                case .value(let interactors):
                    let presenters = interactors
                        .map { ActivityItemPresenter(interactor: $0) }
                    return presenters.map { .activity($0) }
                }
            }
            .map { ActivityItemsSectionViewModel(items: $0) }
            .map { [$0] }
    }

    let longPressRelay: PublishRelay<ActivityItemViewModel> = .init()
    let selectedModelRelay: PublishRelay<ActivityCellItem> = .init()

    // MARK: - Injected

    private let drawerRouter: DrawerRouting
    private let router: ActivityRouterAPI
    private let interactor: ActivityScreenInteractor

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(router: ActivityRouterAPI,
         interactor: ActivityScreenInteractor,
         drawerRouter: DrawerRouting = resolve()) {
        self.drawerRouter = drawerRouter
        self.router = router
        self.interactor = interactor

        selectionButtonViewModel = SelectionButtonViewModel()
        selectionButtonViewModel.shouldShowSeparatorRelay.accept(true)
        selectionButtonViewModel.accessibilityContentRelay.accept(.init(id: AccessibilityId.WalletSelectorView.button, label: ""))
        selectionButtonViewModel.titleAccessibilityRelay.accept(.id(AccessibilityId.WalletSelectorView.titleLabel))
        selectionButtonViewModel.subtitleAccessibilityRelay.accept(.id(AccessibilityId.WalletSelectorView.subtitleLabel))

        selectionButtonViewModel.tap
            .emit(onNext: { [unowned router] in
                router.showWalletSelectionScreen()
            })
            .disposed(by: disposeBag)

        interactor
            .selectedData
            .map { SelectionButtonViewModel.LeadingContent.content(from: $0) }
            .catchErrorJustReturn(.none)
            .bindAndCatch(to: selectionButtonViewModel.leadingContentTypeRelay)
            .disposed(by: disposeBag)

        interactor
            .selectedData
            .map(\.label)
            .catchErrorJustReturn("")
            .bindAndCatch(to: selectionButtonViewModel.titleRelay)
            .disposed(by: disposeBag)

        interactor
            .selectedData
            .map { account in
                switch account {
                case is AccountGroup:
                    return .init(
                        imageName: "icon-disclosure-down-small",
                        renderingMode: .template(.descriptionText)
                    )
                default:
                    return .init(
                        imageName: "icon-disclosure-down-small",
                        accessibility: .none,
                        renderingMode: .template(.descriptionText)
                    )
                }
            }
            .map { .image($0) }
            .catchErrorJustReturn(.empty)
            .bindAndCatch(to: selectionButtonViewModel.trailingContentRelay)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                interactor.activityBalance,
                interactor.fiatCurrency
            )
            .map { balance, fiatCurrency in
                balance.toDisplayString(includeSymbol: true) + " \(fiatCurrency.code)"
            }
            .catchErrorJustReturn("")
            .bindAndCatch(to: selectionButtonViewModel.subtitleRelay)
            .disposed(by: disposeBag)

        selectedModelRelay
            .bind { [weak self] model in
                guard case let .activity(presenter) = model else { return }
                self?.router.showTransactionScreen(with: presenter.viewModel.event)
            }
            .disposed(by: disposeBag)

        longPressRelay
            .bind { [weak self] model in
                self?.router.showActivityShareSheet(model.event)
            }
            .disposed(by: disposeBag)
    }

    func refresh() {
        interactor.refresh()
    }

    // MARK: - Navigation

    /// Should be invoked upon tapping navigation bar leading button
    func navigationBarLeadingButtonPressed() {
        drawerRouter.toggleSideMenu()
    }
}

fileprivate extension SelectionButtonViewModel.LeadingContent {
    static func content(from account: BlockchainAccount) -> SelectionButtonViewModel.LeadingContentType {
        switch account {
        case is AccountGroup:
            return .image(
                .init(name: "icon-card",
                      background: .lightBadgeBackground,
                      cornerRadius: .round,
                      size: .edge(32)
                )
            )
        case is FiatAccount:
            let localImage = account.currencyType.logoResource.local
            return .image(
                .init(
                    name: localImage.name,
                    bundle: localImage.bundle,
                    background: .fiat,
                    offset: 0,
                    cornerRadius: .value(8.0),
                    size: .edge(32)
                )
            )
        default:
            let localImage = account.currencyType.logoResource.local
            return .image(
                .init(
                    name: localImage.name,
                    bundle: localImage.bundle,
                    background: .clear,
                    offset: 0,
                    cornerRadius: .round,
                    size: .edge(32)
                )
            )
        }
    }
}
