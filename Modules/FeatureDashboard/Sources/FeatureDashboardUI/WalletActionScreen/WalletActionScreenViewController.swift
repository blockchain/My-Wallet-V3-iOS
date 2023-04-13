// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxDataSources
import RxSwift

final class WalletActionScreenViewController: UIViewController {

    // MARK: - Private Types

    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<WalletActionItemsSectionViewModel>

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets

    private let tableView = SelfSizingTableView()

    // MARK: - Injected

    private let presenter: WalletActionScreenPresenting

    // MARK: - Setup

    init(using presenter: WalletActionScreenPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        view.addSubview(tableView)
        tableView.fillSuperview(usesSafeAreaLayoutGuide: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.register(WalletActionTableViewCell.self)
        tableView.separatorInset = .zero
        tableView.separatorColor = .lightBorder

        let dataSource = RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self else { return UITableViewCell() }
            let cell: UITableViewCell

            switch item {
            case .balance(let presenter):
                cell = currentBalanceCell(for: indexPath, presenter: presenter)
            case .default(let presenter):
                cell = defaultActionCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
        dataSource.animationConfiguration = AnimationConfiguration(
            insertAnimation: .none,
            reloadAnimation: .none,
            deleteAnimation: .none
        )

        presenter.sections
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(WalletActionCellType.self)
            .bindAndCatch(to: presenter.selectionRelay)
            .disposed(by: disposeBag)
    }
}

extension WalletActionScreenViewController {

    // MARK: - Accessors

    private func currentBalanceCell(
        for indexPath: IndexPath,
        presenter: CurrentBalanceCellPresenter
    ) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func defaultActionCell(
        for indexPath: IndexPath,
        presenter: WalletActionCellPresenter
    ) -> UITableViewCell {
        let cell = tableView.dequeue(WalletActionTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
