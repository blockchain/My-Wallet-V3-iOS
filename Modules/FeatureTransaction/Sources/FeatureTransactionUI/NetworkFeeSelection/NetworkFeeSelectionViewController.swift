// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import RIBs
import RxCocoa
import RxDataSources
import RxSwift

protocol NetworkFeeSelectionPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class NetworkFeeSelectionViewController: UIViewController, NetworkFeeSelectionViewControllable, UITableViewDelegate {

    // MARK: - Private Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<NetworkFeeSelectionSectionModel>

    // MARK: - RIBs

    weak var listener: NetworkFeeSelectionPresentableListener?

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let tableView = SelfSizingTableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.fillSuperview(usesSafeAreaLayoutGuide: true)
        tableView.layoutToSuperview(.top)
        setupTableView()
    }

    // MARK: - NetworkFeeSelectionPresentable

    func connect(state: Driver<NetworkFeeSelectionPresenter.State>) -> Driver<NetworkFeeSelectionEffects> {
        disposeBag = DisposeBag()

        /// Wait for the screen to load.
        let stateWait: Driver<NetworkFeeSelectionPresenter.State> =
            rx.viewDidLoad
                .asDriver()
                .flatMap { _ in
                    state
                }

        /// Setup `ButtonViewModel` that dismisses the view.
        let buttonView: ButtonViewModel = .primary(with: LocalizationConstants.okString)
        let tap: Driver<NetworkFeeSelectionEffects> = buttonView
            .tap
            .flatMap { _ in Driver.just(.okTapped) }

        /// Only enabled the `OK` button if the user does not have
        /// `Custom` as the fee selection type *or* does have `Custom`
        /// enabled but does not have a valid custom fee entered.
        stateWait
            .flatMap(\.isOkEnabled)
            .drive(buttonView.isEnabledRelay)
            .disposed(by: disposeBag)

        let items: Driver<[NetworkFeeSelectionSectionModel]> = stateWait
            .map(\.sections)
            /// There should only be one section in this screen,
            .compactMap(\.first)
            /// Append the `ButtonViewModel` to the bottom of the `tableView`
            .map { model -> NetworkFeeSelectionSectionModel in
                var value = model
                value.items.append(.button(buttonView))
                return value
            }
            /// Return the modified items
            .map { [$0] }

        let dataSource = RxDataSource(
            configureCell: { [weak self] _, _, indexPath, item -> UITableViewCell in
                guard let self else { return UITableViewCell() }
                switch item {
                case .label(let content):
                    return labelCell(with: content, row: indexPath.row)
                case .radio(let presenter):
                    return radioCell(presenter: presenter, for: indexPath.row)
                case .button(let viewModel):
                    return buttonsCell(viewModel: viewModel, for: indexPath.row)
                case .separator:
                    return separatorCell(for: indexPath.row)
                }
            }
        )

        items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        let selectionEffect = tableView.rx
            .itemSelected
            .map(\.row)
            .map { row -> NetworkFeeSelectionEffects in
                /// Only the radio items are tappable and the
                /// `NetworkFeeSelectionSectionItem` does not know
                /// if it's a priority or regular fee, so we need to derive
                /// the effect based on the row selected.
                switch row {
                case 2:
                    return .selectedFee(.regular)
                case 4:
                    return .selectedFee(.priority)
                default:
                    return .none
                }
            }
            .asDriverCatchError()

        return Driver.merge(selectionEffect, tap)
            .asDriver(onErrorJustReturn: .none)
    }

    private func setupTableView() {
        tableView.register(RadioLineItemTableViewCell.self)
        tableView.register(SeparatorTableViewCell.self)
        tableView.register(LabelTableViewCell.self)
        tableView.registerNibCell(ButtonsTableViewCell.self, in: .platformUIKit)
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func buttonsCell(viewModel: ButtonViewModel, for row: Int) -> UITableViewCell {
        let cell = tableView.dequeue(
            ButtonsTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.models = [viewModel]
        return cell
    }

    private func radioCell(presenter: RadioLineItemCellPresenter, for row: Int) -> UITableViewCell {
        let cell = tableView.dequeue(
            RadioLineItemTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.presenter = presenter
        return cell
    }

    private func labelCell(with content: LabelContent, row: Int) -> UITableViewCell {
        let cell = tableView.dequeue(
            LabelTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.content = content
        return cell
    }

    private func separatorCell(for row: Int) -> UITableViewCell {
        tableView.dequeue(SeparatorTableViewCell.self, for: IndexPath(row: row, section: 0))
    }
}
