// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureActivityDomain
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit

public final class ActivityScreenViewController: BaseScreenViewController {

    // MARK: - Private Types

    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<ActivityItemsSectionViewModel>

    // MARK: - UI Properties

    @IBOutlet private var selectionButtonView: SelectionButtonView!
    @IBOutlet private var emptyActivityTitleLabel: UILabel!
    @IBOutlet private var emptyActivitySubtitleLabel: UILabel!
    @IBOutlet private var emptyActivityImageView: UIImageView!
    @IBOutlet private var empyActivityStackView: UIStackView!
    @IBOutlet private var tableView: SelfSizingTableView!
    private var refreshControl: UIRefreshControl!

    // MARK: - Injected

    private let longPressRelay = BehaviorRelay<ActivityItemViewModel?>(value: nil)
    private let presenter: ActivityScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(services: ActivityServiceContaining = resolve(), drawerRouting: DrawerRouting = resolve()) {
        let router = ActivityRouter(container: services)
        let interactor = ActivityScreenInteractor(serviceContainer: services)
        self.presenter = ActivityScreenPresenter(router: router, interactor: interactor, drawerRouter: drawerRouting)
        super.init(nibName: ActivityScreenViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        selectionButtonView.viewModel = presenter.selectionButtonViewModel
        setupNavigationBar()
        setupTableView()
        setupEmptyState()

        let longPress = UILongPressGestureRecognizer()
        longPress
            .rx
            .event
            .compactMap { [tableView] gesture -> ActivityItemViewModel? in
                guard gesture.state == .began else { return nil }
                let location = gesture.location(in: self.tableView)
                guard let indexPath = tableView?.indexPathForRow(at: location) else { return nil }
                guard let cell = tableView?.cellForRow(at: indexPath) as? ActivityItemTableViewCell else {
                    return nil
                }
                return cell.presenter.viewModel
            }
            .bindAndCatch(to: presenter.longPressRelay)
            .disposed(by: disposeBag)

        tableView.addGestureRecognizer(longPress)

        rx.viewDidAppear
            .take(1)
            .bind { [weak self] _ in
                self?.presenter.refresh()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        let model = presenter.screenNavigationModel
        set(
            barStyle: model.barStyle,
            leadingButtonStyle: model.leadingButton,
            trailingButtonStyle: model.trailingButton
        )
        titleViewStyle = model.titleViewStyle
    }

    private func setupEmptyState() {
        emptyActivityTitleLabel.content = presenter.emptyActivityTitle
        emptyActivitySubtitleLabel.content = presenter.emptyActivitySubtitle

        let alpha = presenter
            .emptySubviewsVisibility
            .map(\.defaultAlpha)

        alpha
            .drive(emptyActivitySubtitleLabel.rx.alpha)
            .disposed(by: disposeBag)

        alpha
            .drive(emptyActivityTitleLabel.rx.alpha)
            .disposed(by: disposeBag)

        alpha
            .drive(emptyActivityImageView.rx.alpha)
            .disposed(by: disposeBag)

        alpha
            .map { $0 == 0 }
            .drive(empyActivityStackView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView()
        tableView.register(SelectionButtonTableViewCell.self)
        tableView.registerNibCell(ActivityItemTableViewCell.self, in: .module)
        tableView.registerNibCell(ActivitySkeletonTableViewCell.self, in: .module)

        let animation = AnimationConfiguration(
            insertAnimation: .automatic,
            reloadAnimation: .automatic,
            deleteAnimation: .automatic
        )

        let dataSource = RxDataSource(
            animationConfiguration: animation,
            configureCell: { [weak self] _, _, indexPath, item in
                guard let self else { return UITableViewCell() }
                let cell: UITableViewCell

                switch item {
                case .selection(let viewModel):
                    cell = selectionButtonTableViewCell(for: indexPath, viewModel: viewModel)
                case .skeleton:
                    cell = skeletonCell(for: indexPath)
                case .activity(let presenter):
                    cell = activityItemTableViewCell(for: indexPath, presenter: presenter)
                }
                cell.selectionStyle = .none
                return cell
            }
        )

        presenter.sectionsObservable
            .observe(on: MainScheduler.asyncInstance)
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        tableView.rx
            .modelSelected(ActivityCellItem.self)
            .bindAndCatch(to: presenter.selectedModelRelay)
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override public func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }

    // MARK: - UITableView refresh

    @objc
    private func refresh() {
        presenter.refresh()
        refreshControl.endRefreshing()
    }

    // MARK: - Private Functions

    private func skeletonCell(for indexPath: IndexPath) -> ActivitySkeletonTableViewCell {
        let cell = tableView.dequeue(ActivitySkeletonTableViewCell.self, for: indexPath)
        return cell
    }

    private func activityItemTableViewCell(
        for indexPath: IndexPath,
        presenter: ActivityItemPresenter
    ) -> ActivityItemTableViewCell {
        let cell = tableView.dequeue(ActivityItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func selectionButtonTableViewCell(
        for indexPath: IndexPath, viewModel: SelectionButtonViewModel
    ) -> SelectionButtonTableViewCell {
        let cell = tableView.dequeue(
            SelectionButtonTableViewCell.self,
            for: indexPath
        )
        cell.viewModel = viewModel
        return cell
    }
}
