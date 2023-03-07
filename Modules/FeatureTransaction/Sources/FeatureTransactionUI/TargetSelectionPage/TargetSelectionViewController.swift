// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftformat:disable all

import BlockchainComponentLibrary
import PlatformUIKit
import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit
import UIKit

protocol TargetSelectionPageViewControllable: ViewControllable {
    func connect(state: Driver<TargetSelectionPagePresenter.State>) -> Driver<TargetSelectionPageInteractor.Effects>
}

final class TargetSelectionViewController: BaseScreenViewController, TargetSelectionPageViewControllable {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<TargetSelectionPageSectionModel>

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let shouldOverrideNavigationEffects: Bool
    private let actionButton = ButtonView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerRelay = BehaviorRelay<HeaderBuilder?>(value: nil)
    private let backButtonRelay = PublishRelay<Void>()
    private let closeButtonRelay = PublishRelay<Void>()

    private var keyboardInteractionController: KeyboardInteractionController!

    private lazy var dataSource: RxDataSource = {
        RxDataSource(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .none,
                reloadAnimation: .none,
                deleteAnimation: .none
            ),
            configureCell: { [weak self] _, _, indexPath, item in
                guard let self = self else { return UITableViewCell() }

                let cell: UITableViewCell
                switch item.presenter {
                case .cardView(let model):
                    cell = self.cardCell(for: indexPath, model: model)
                case .radioSelection(let presenter):
                    cell = self.radioCell(for: indexPath, presenter: presenter)
                case .singleAccount(let presenter):
                    cell = self.balanceCell(for: indexPath, presenter: presenter)
                case .walletInputField(let viewModel):
                    cell = self.walletTextfieldCell(for: indexPath, viewModel: viewModel)
                    cell.backgroundColor = .clear
                }
                cell.selectionStyle = .none
                return cell
            }
        )
    }()

    init(shouldOverrideNavigationEffects: Bool) {
        self.shouldOverrideNavigationEffects = shouldOverrideNavigationEffects
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { unimplemented() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardInteractionController = KeyboardInteractionController(in: self)
        setupUI()
    }

    override func navigationBarLeadingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarLeadingButtonPressed()
            return
        }
        switch leadingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        case .back:
            backButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    override func navigationBarTrailingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarTrailingButtonPressed()
            return
        }
        switch trailingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    func connect(state: Driver<TargetSelectionPagePresenter.State>) -> Driver<TargetSelectionPageInteractor.Effects> {
        disposeBag = DisposeBag()
        tableView.delegate = self

        let stateWait: Driver<TargetSelectionPagePresenter.State> =
            rx.viewDidLoad
                .asDriver()
                .flatMap { _ in
                    state
                }

        stateWait
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                self.titleViewStyle = model.titleViewStyle
                self.set(
                    barStyle: model.barStyle,
                    leadingButtonStyle: model.leadingButton,
                    trailingButtonStyle: model.trailingButton
                )
            }
            .disposed(by: disposeBag)

        stateWait.map(\.sections)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        stateWait.map(\.actionButtonModel)
            .drive(actionButton.rx.viewModel)
            .disposed(by: disposeBag)

        let selectionEffect = tableView.rx
            .modelSelected(TargetSelectionPageSectionModel.Item.self)
            .filter(\.isSelectable)
            .compactMap(\.account)
            .map { account in TargetSelectionPageInteractor.Effects.select(account) }
            .asDriverCatchError()

        let backButtonEffect = backButtonRelay
            .map { TargetSelectionPageInteractor.Effects.back }
            .asDriverCatchError()

        let closeButtonEffect = closeButtonRelay
            .map { TargetSelectionPageInteractor.Effects.closed }
            .asDriverCatchError()

        let nextButtonEffect = stateWait
            .map(\.actionButtonModel)
            .flatMap { viewModel -> Signal<Void> in
                viewModel.tap
            }
            .asObservable()
            .map { _ in TargetSelectionPageInteractor.Effects.next }
            .asDriverCatchError()

        return .merge(
            backButtonEffect,
            closeButtonEffect,
            selectionEffect,
            nextButtonEffect
        )
    }

    // MARK: - Private Methods

    private func setupUI() {
        tableView.backgroundColor = .background
        view.backgroundColor = .background
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.register(RadioAccountTableViewCell.self)
        tableView.register(HostingTableViewCell<AlertCard<EmptyView>>.self)
        tableView.register(TextFieldTableViewCell.self)

        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .leading, .trailing)

        view.addSubview(actionButton)
        actionButton.layoutToSuperview(.centerX)
        actionButton.layout(edge: .top, to: .bottom, of: tableView, offset: Spacing.inner)
        actionButton.layoutToSuperview(.leading, usesSafeAreaLayoutGuide: true, offset: Spacing.outer)
        actionButton.layoutToSuperview(.trailing, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
        actionButton.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
        actionButton.layout(dimension: .height, to: ButtonSize.Standard.height)
    }

    private func walletTextfieldCell(for indexPath: IndexPath, viewModel: TextFieldViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(TextFieldTableViewCell.self, for: indexPath)
        cell.setup(
            viewModel: viewModel,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: tableView
        )
        cell.horizontalInset = 0
        cell.topInset = 0
        return cell
    }

    private func radioCell(for indexPath: IndexPath, presenter: RadioAccountCellPresenter) -> UITableViewCell {
        let cell = tableView.dequeue(RadioAccountTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func balanceCell(for indexPath: IndexPath, presenter: CurrentBalanceCellPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func cardCell(for indexPath: IndexPath, model: TargetSelectionCardModel) -> UITableViewCell {
        let cell = tableView.dequeue(HostingTableViewCell<AlertCard<EmptyView>>.self, for: indexPath)
        let alertCard = AlertCard(
            title: model.title,
            message: model.subtitle,
            backgroundColor: .white,
            onCloseTapped: model.didClose
        )
        cell.host(
            alertCard,
            parent: self,
            height: nil,
            showSeparator: false,
            backgroundColor: .clear
        )
        return cell
    }
}

extension TargetSelectionViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dataSource[section].header.view(fittingWidth: view.bounds.width, customHeight: nil)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        dataSource[section].header.defaultHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.section].items[indexPath.row].presenter {
        case .cardView:
            return UITableView.automaticDimension
        case .radioSelection,
             .singleAccount,
             .walletInputField:
            return 77
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.section].items[indexPath.row].presenter {
        case .cardView:
            return UITableView.automaticDimension
        case .radioSelection,
             .singleAccount,
             .walletInputField:
            return 77
        }
    }
}
