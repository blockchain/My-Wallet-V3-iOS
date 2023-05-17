// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

final class AddNewPaymentMethodViewController: BaseScreenViewController,
    AddNewPaymentMethodPresentable,
    AddNewPaymentMethodViewControllable
{

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<AddNewPaymentMethodCellSectionModel>

    // MARK: - Views

    private lazy var tableView = UITableView()

    // MARK: - Accessors

    private let disposeBag = DisposeBag()
    private let closeTriggerred = PublishSubject<Void>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .semantic.light
        setupNavigationBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func connect(action: Driver<AddNewPaymentMethodAction>) -> Driver<AddNewPaymentMethodEffects> {
        let items: Driver<[AddNewPaymentMethodCellSectionModel]> = action
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
                case .paymentMethodTypeView(let viewModel):
                    return paymentMethodTypeViewCell(for: indexPath, viewModel: viewModel)
                case .suggestedPaymentMethod(let viewModel):
                    return suggestedPaymentMethodCell(for: indexPath, viewModel: viewModel)
                }
            }
        )

        items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        let closeTriggered = closeTriggerred
            .map { _ in AddNewPaymentMethodEffects.closeFlow }
            .asDriverCatchError()

        return closeTriggered
    }

    // MARK: - Navigation

    override func navigationBarTrailingButtonPressed() {
        closeTriggerred.onNext(())
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.SimpleBuy.AddPaymentMethodSelectionScreen.title)
        setStandardDarkContentStyle()
    }

    private func setupTableView() {
        tableView.backgroundColor = .semantic.light
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ExplainedActionTableViewCell.self)
        tableView.register(HostingTableViewCell<PaymentMethodTypeView>.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)

        tableView.layoutToSuperview(axis: .horizontal)
        tableView.layoutToSuperview(axis: .vertical)
    }

    private func paymentMethodTypeViewCell(
        for indexPath: IndexPath,
        viewModel: PaymentMethodTypeView
    ) -> UITableViewCell {
        let cell = tableView.dequeue(HostingTableViewCell<PaymentMethodTypeView>.self, for: indexPath)
        cell.host(
            viewModel,
            parent: self,
            height: nil,
            showSeparator: false,
            backgroundColor: .clear
        )
        return cell
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
