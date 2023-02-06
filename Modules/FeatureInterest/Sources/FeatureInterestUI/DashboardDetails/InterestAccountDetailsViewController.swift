// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import RxDataSources
import RxSwift

public final class InterestAccountDetailsViewController: BaseScreenViewController {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<DetailSectionViewModel>

    // MARK: - Private Properties

    private let tableView: SelfSizingTableView
    private let presenter: InterestAccountDetailsScreenPresenter
    private let disposeBag = DisposeBag()

    public init(presenter: InterestAccountDetailsScreenPresenter) {
        self.presenter = presenter
        self.tableView = SelfSizingTableView()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.fillSuperview(usesSafeAreaLayoutGuide: true)
        tableView.separatorColor = .background
        tableView.separatorInset = .zero
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.registerNibCell(ButtonsTableViewCell.self, in: .platformUIKit)
        tableView.registerNibCell(LineItemTableViewCell.self, in: .platformUIKit)
        tableView.register(FooterTableViewCell.self)

        let dataSource = RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.presenter {
            case .buttons(let viewModels):
                cell = self.buttonsCell(for: indexPath, viewModels: viewModels)
            case .currentBalance(let presenter):
                cell = self.balanceCell(for: indexPath, presenter: presenter)
            case .footer(let presenter):
                cell = self.footerCell(for: indexPath, presenter: presenter)
            case .lineItem(let type):
                switch type {
                case .default(let presenter):
                    cell = self.lineItemCell(for: indexPath, presenter: presenter)
                }
            }
            cell.selectionStyle = .none
            return cell
        })

        presenter.sectionObservable
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        titleViewStyle = presenter.titleView
    }

    override public func navigationBarTrailingButtonPressed() {
        super.navigationBarTrailingButtonPressed()
        dismiss(animated: true)
    }
}

extension InterestAccountDetailsViewController {

    private func buttonsCell(
        for indexPath: IndexPath,
        viewModels: [ButtonViewModel]
    ) -> ButtonsTableViewCell {
        let cell = tableView.dequeue(ButtonsTableViewCell.self, for: indexPath)
        cell.models = viewModels
        return cell
    }

    private func balanceCell(
        for indexPath: IndexPath,
        presenter: CurrentBalanceCellPresenter
    ) -> CurrentBalanceTableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func footerCell(
        for indexPath: IndexPath,
        presenter: FooterTableViewCellPresenter
    ) -> FooterTableViewCell {
        let cell = tableView.dequeue(FooterTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func lineItemCell(
        for indexPath: IndexPath,
        presenter: LineItemCellPresenting
    ) -> LineItemTableViewCell {
        let cell = tableView.dequeue(LineItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
