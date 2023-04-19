// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit

final class SettingsViewController: BaseScreenViewController {

    // MARK: - Accessibility

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.SettingsCell
    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<SettingsSectionViewModel>

    // MARK: - Private Properties

    private let tableView = UITableView(
        frame: UIScreen.main.bounds,
        style: .insetGrouped
    )
    private let presenter: SettingsScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(presenter: SettingsScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.settings
        setupTableView()
        presenter.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        presenter.refresh()
    }

    // MARK: - Private Functions

    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.settings)
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        trailingButtonStyle = .close
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.layoutToSuperview(axis: .horizontal)
        tableView.layoutToSuperview(.bottom)
        tableView.layoutToSuperview(.top, usesSafeAreaLayoutGuide: true)

        let mainBoundsWidth = UIScreen.main.bounds.width
        let tableFooterFrame = CGRect(
            origin: .zero,
            size: CGSize(
                width: mainBoundsWidth,
                height: AboutView.estimatedHeight(for: mainBoundsWidth)
            )
        )
        let tableFooterView = AboutView(frame: tableFooterFrame)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = .background
        view.backgroundColor = .background
        tableView.delegate = self
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 18
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.tableFooterView = tableFooterView
        tableView.tableFooterView?.frame = tableFooterFrame
        tableView.registerNibCell(SwitchTableViewCell.self, in: .module)
        tableView.registerNibCell(ReferralTableViewCell.self, in: .module)
        tableView.registerNibCell(ClipboardTableViewCell.self, in: .module)
        tableView.registerNibCell(BadgeTableViewCell.self, in: .module)
        tableView.registerNibCell(CommonTableViewCell.self, in: .module)
        tableView.registerNibCell(AddPaymentMethodTableViewCell.self, in: .module)
        tableView.register(LinkedBankTableViewCell.self)
        tableView.registerNibCell(LinkedCardTableViewCell.self, in: .module)
        tableView.register(SettingsSkeletonTableViewCell.self)
        tableView.registerHeaderView(TableHeaderView.objectName, bundle: .module)

        let dataSource = RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.cellType {
            case .badge(_, let presenter):
                cell = badgeCell(for: indexPath, presenter: presenter)
            case .clipboard(let type):
                cell = clipboardCell(for: indexPath, viewModel: type.viewModel)
            case .common(let type, let presenter):
                cell = commonCell(for: indexPath, viewModel: type.viewModel(presenter: presenter))
            case .cards(let type):
                switch type {
                case .skeleton:
                    cell = skeletonCell(for: indexPath)
                case .add(let presenter):
                    cell = addPaymentMethodCell(for: indexPath, presenter: presenter)
                case .linked(let presenter):
                    cell = linkedCardCell(for: indexPath, presenter: presenter)
                }
            case .banks(let type):
                switch type {
                case .skeleton:
                    cell = skeletonCell(for: indexPath)
                case .add(let presenter):
                    cell = addPaymentMethodCell(for: indexPath, presenter: presenter)
                case .linked(let viewModel):
                    cell = linkedBankCell(for: indexPath, viewModel: viewModel)
                }
            case .switch(_, let presenter):
                cell = switchCell(for: indexPath, presenter: presenter)
            case .refferal(_, let viewModel):
                cell = referralCell(for: indexPath, viewModel: viewModel)
            }
            cell.selectionStyle = .none
            return cell
        })

        presenter.sectionObservable
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(SettingsCellViewModel.self)
            .bindAndCatch(weak: self) { (self, model) in
                model.recordSelection()
                self.presenter.actionRelay.accept(model.action)
            }
            .disposed(by: disposeBag)
    }

    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.objectName) as? TableHeaderView else {
            return nil
        }
        let section = presenter.sectionArrangement[section]
        let viewModel = TableHeaderViewModel.settings(title: section.sectionTitle)
        header.viewModel = viewModel
        return header
    }

    private func skeletonCell(for indexPath: IndexPath) -> SettingsSkeletonTableViewCell {
        let cell = tableView.dequeue(SettingsSkeletonTableViewCell.self, for: indexPath)
        return cell
    }

    private func switchCell(for indexPath: IndexPath, presenter: SwitchCellPresenting) -> SwitchTableViewCell {
        let cell = tableView.dequeue(SwitchTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func clipboardCell(for indexPath: IndexPath, viewModel: ClipboardCellViewModel) -> ClipboardTableViewCell {
        let cell = tableView.dequeue(ClipboardTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }

    private func commonCell(for indexPath: IndexPath, viewModel: CommonCellViewModel) -> CommonTableViewCell {
        let cell = tableView.dequeue(CommonTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }

    private func addPaymentMethodCell(for indexPath: IndexPath, presenter: AddPaymentMethodCellPresenter) -> AddPaymentMethodTableViewCell {
        let cell = tableView.dequeue(AddPaymentMethodTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func linkedCardCell(
        for indexPath: IndexPath,
        presenter: LinkedCardCellPresenter
    ) -> LinkedCardTableViewCell {
        let cell = tableView.dequeue(LinkedCardTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func linkedBankCell(
        for indexPath: IndexPath,
        viewModel: BeneficiaryLinkedBankViewModel
    ) -> LinkedBankTableViewCell {
        let cell = tableView.dequeue(LinkedBankTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }

    private func badgeCell(for indexPath: IndexPath, presenter: BadgeCellPresenting) -> BadgeTableViewCell {
        let cell = tableView.dequeue(BadgeTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func referralCell(
        for indexPath: IndexPath,
        viewModel: ReferralTableViewCellViewModel
    ) -> ReferralTableViewCell {
        let cell = tableView.dequeue(ReferralTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
}
