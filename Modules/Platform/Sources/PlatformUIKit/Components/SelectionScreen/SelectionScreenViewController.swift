// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class SelectionScreenViewController: BaseScreenViewController {

    // MARK: - IBOutlets

    private let tableView: UITableView = .init()

    // MARK: - Injected

    private let presenter: SelectionScreenPresenter

    // MARK: - Accessors

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    public init(presenter: SelectionScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchController()
        setupTableView()

        view.backgroundColor = UIColor.white
        view.isOpaque = true

        presenter.dismiss
            .emit(onNext: { [weak self] in
                guard let self else { return }
                let completion = {
                    self.removeFromHierarchy()
                    self.presenter.previousTapped()
                }
                if navigationItem.searchController?.isActive ?? false {
                    navigationItem.searchController?.dismiss(animated: true, completion: completion)
                } else {
                    completion()
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        setStandardDarkContentStyle()
    }

    private func setupSearchController() {
        let searchController = SearchController(placeholderText: presenter.searchBarPlaceholder)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        searchController.text
            .bindAndCatch(to: presenter.searchTextRelay)
            .disposed(by: disposeBag)
    }

    private func setupTableView() {

        // Table view setup

        view.addSubview(tableView)
        tableView.layoutToSuperview(.leading, .trailing, .top, .bottom)

        if let viewModel = presenter.tableHeaderViewModel {
            let width = tableView.bounds.width
            let height = SelectionScreenTableHeaderView.estimatedHeight(for: width, model: viewModel)
            let headerView = SelectionScreenTableHeaderView(frame: .init(
                origin: .zero,
                size: .init(
                    width: width,
                    height: height
                )
            )
            )
            headerView.viewModel = viewModel
            tableView.tableHeaderView = headerView
        }

        tableView.register(SelectionItemTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        // Table view binding

        let displayPresenters = presenter
            .displayPresenters
            .share(replay: 1)

        displayPresenters
            .bind(
                to: tableView.rx.items(
                    cellIdentifier: SelectionItemTableViewCell.objectName,
                    cellType: SelectionItemTableViewCell.self
                ),
                curriedArgument: { _, presenter, cell in
                    cell.presenter = presenter
                }
            )
            .disposed(by: disposeBag)

        displayPresenters
            .filter { !$0.isEmpty }
            .flatMap(weak: self) { (self, _) in
                self.presenter.preselection
            }
            .take(1)
            .asSingle()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] index in
                self?.tableView.scrollToRow(
                    at: IndexPath(row: index, section: 0),
                    at: .middle,
                    animated: true
                )
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override public func navigationBarLeadingButtonPressed() {
        super.navigationBarLeadingButtonPressed()
        presenter.previousTapped()
    }

    override public func navigationBarTrailingButtonPressed() {
        super.navigationBarTrailingButtonPressed()
        presenter.previousTapped()
    }
}
