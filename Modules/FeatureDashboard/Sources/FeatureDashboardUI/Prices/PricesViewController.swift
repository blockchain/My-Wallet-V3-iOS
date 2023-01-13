// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit

final class PricesViewController: BaseScreenViewController {

    // MARK: - Private Types

    private typealias LocalizedString = LocalizationConstants.Dashboard.Prices
    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<PricesViewModel>

    // MARK: - Private Properties

    private let app: AppProtocol
    private let disposeBag = DisposeBag()
    private let presenter: PricesScreenPresenter
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let customSelectionActionClosure: PricesCustomSelectionActionClosure?

    // MARK: - Setup

    init(
        app: AppProtocol = DIKit.resolve(),
        presenter: PricesScreenPresenter,
        customSelectionActionClosure: PricesCustomSelectionActionClosure? = nil
    ) {
        self.app = app
        self.presenter = presenter
        self.customSelectionActionClosure = customSelectionActionClosure
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        presenter.setup()
        tableView.reloadData()
        presenter.refreshRelay.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(searchBar)

        searchBar.placeholder = LocalizedString.searchPlaceholder
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.isTranslucent = false

        searchBar.layoutToSuperview(axis: .horizontal, offset: 12)
        tableView.layoutToSuperview(axis: .horizontal)
        searchBar.layoutToSuperview(.top, offset: 14)
        searchBar.layout(edge: .bottom, to: .top, of: tableView)
        tableView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        tableView.separatorColor = .clear
        tableView.keyboardDismissMode = .onDrag

        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.identifier)
        tableView.register(PricesTableViewCell.self, forCellReuseIdentifier: PricesTableViewCell.identifier)

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: presenter.refreshRelay)
            .disposed(by: disposeBag)
        refreshControl.rx
            .controlEvent(.valueChanged)
            .map { false }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        searchBar.rx.text
            .map { $0 ?? "" }
            .asObservable()
            .bind(to: presenter.searchRelay)
            .disposed(by: disposeBag)

        searchBar.rx.textDidBeginEditing
            .bind(onNext: { [weak self] _ in
                self?.searchBar.setShowsCancelButton(true, animated: true)
            })
            .disposed(by: disposeBag)

        searchBar.rx.textDidEndEditing
            .bind(onNext: { [weak self] _ in
                self?.searchBar.setShowsCancelButton(false, animated: true)
            })
            .disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .map { nil }
            .bind(to: searchBar.rx.text)
            .disposed(by: disposeBag)

        Observable<Void>
            .merge(
                searchBar.rx.cancelButtonClicked.asObservable(),
                searchBar.rx.searchButtonClicked.asObservable()
            )
            .bind(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        let dataSource = RxDataSource(
            animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { _, tableView, indexPath, item in
                switch item {
                case .emptyState(let content):
                    let cell = tableView.dequeue(LabelTableViewCell.self, for: indexPath)
                    cell.content = content
                    cell.selectionStyle = .none
                    return cell
                case .currency(_, let presenter):
                    let cell = tableView.dequeue(PricesTableViewCell.self, for: indexPath)
                    cell.presenter = presenter()
                    return cell
                }
            }
        )

        tableView.rx.modelSelected(PricesCellType.self)
            .subscribe(onNext: { [weak self] model in
                switch model {
                case .emptyState:
                    break
                case .currency(let currency, _):
                    if let customSelectionActionClosure = self?.customSelectionActionClosure {
                        customSelectionActionClosure(currency)
                    } else {
                        self?.app.post(
                            action: blockchain.ux.asset.select.then.enter.into,
                            value: blockchain.ux.asset[currency.code],
                            context: [blockchain.ux.asset.select.origin: "PRICES"]
                        )
                    }
                }
            })
            .disposed(by: disposeBag)

        presenter.sections
            .observe(on: MainScheduler.asyncInstance)
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }
}

extension PricesViewController: SegmentedViewScreenViewController {
    func adjustInsetForBottomButton(withHeight height: CGFloat) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
    }
}
