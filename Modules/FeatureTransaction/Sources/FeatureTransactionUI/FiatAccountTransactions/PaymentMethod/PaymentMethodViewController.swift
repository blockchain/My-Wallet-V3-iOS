// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformUIKit
import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit

final class PaymentMethodViewController: BaseScreenViewController,
    PaymentMethodViewControllable
{

    weak var listener: PaymentMethodListener?

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<PaymentMethodCellSectionModel>

    // MARK: - Views

    private lazy var tableView = UITableView()

    // MARK: - Accessors

    private let disposeBag = DisposeBag()
    private let closeTriggerred = PublishSubject<Void>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.background
        setupNavigationBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func connect(action: Driver<PaymentMethodAction>) -> Driver<PaymentMethodEffects> {
        let items: Driver<[PaymentMethodCellSectionModel]> = action
            .flatMap { action in
                switch action {
                case .items(let viewModels):
                    return .just(viewModels)
                }
            }

        let dataSource = RxDataSource(
            configureCell: { [weak self] _, _, indexPath, item -> UITableViewCell in
                guard let self else { return UITableViewCell() }
                switch item {
                case .suggestedPaymentMethod(let viewModel):
                    return suggestedPaymentMethodCell(for: indexPath, viewModel: viewModel)
                }
            }
        )

        items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        let closeTriggered = closeTriggerred
            .map { _ in PaymentMethodEffects.closeFlow }
            .asDriverCatchError()

        return closeTriggered
    }

    // MARK: - Navigation

    override func navigationBarTrailingButtonPressed() {
        closeTriggerred.onNext(())
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        // TODO: Localization
        titleViewStyle = .text(value: "Add a Bank Account")
        setStandardDarkContentStyle()
    }

    private func setupTableView() {
        tableView.backgroundColor = UIColor.semantic.background
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ExplainedActionTableViewCell.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)

        tableView.layoutToSuperview(axis: .horizontal)
        tableView.layoutToSuperview(axis: .vertical)
    }

    private func suggestedPaymentMethodCell(
        for indexPath: IndexPath,
        viewModel: ExplainedActionViewModel
    ) -> UITableViewCell {
        let cell = tableView.dequeue(ExplainedActionTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
}
