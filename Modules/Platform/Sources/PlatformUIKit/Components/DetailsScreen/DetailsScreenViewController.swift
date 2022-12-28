// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxRelay
import RxSwift

public final class DetailsScreenViewController: BaseTableViewController {

    // MARK: - Injected

    private let presenter: DetailsScreenPresenterAPI

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let keyboardObserver = KeyboardObserver()
    private var keyboardInteractionController: KeyboardInteractionController!

    // MARK: - Setup

    public init(presenter: DetailsScreenPresenterAPI) {
        self.presenter = presenter
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        extendSafeAreaUnderNavigationBar = presenter.extendSafeAreaUnderNavigationBar
        tableView.delegate = self
        tableView.dataSource = self
        tableView.selfSizingBehaviour = .fill
        setupTableView()
        setupNavigationBar()
        for viewModel in presenter.disclaimers {
            let disclaimerView = DisclaimerView()
            disclaimerView.viewModel = viewModel
            addStickyBottomView(disclaimerView)
        }
        for viewModel in presenter.buttons {
            let buttonView = ButtonView()
            buttonView.viewModel = viewModel
            buttonView.layout(dimension: .height, to: ButtonSize.Standard.height)
            addStickyBottomView(buttonView)
        }
        keyboardInteractionController = .init(in: scrollView)
        setupPresenter()
        setupKeyboardObserver()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.setup()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        keyboardObserver.remove()
        super.viewWillDisappear(animated)
    }

    // MARK: - Setup

    private func setupPresenter() {
        presenter
            .reload
            .emit(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        presenter.viewDidLoad()
    }

    private func setupKeyboardObserver() {
        keyboardObserver.state
            .bindAndCatch(weak: self) { (self, state) in
                switch state.visibility {
                case .visible:
                    self.contentBottomConstraint.constant = -(state.payload.height + self.view.safeAreaInsets.bottom)
                case .hidden:
                    self.contentBottomConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(NoticeTableViewCell.self)
        tableView.register(InteractableTextTableViewCell.self)
        tableView.register(MultiBadgeTableViewCell.self)
        tableView.register(LabelTableViewCell.self)
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(BadgeNumberedTableViewCell.self)
        tableView.registerNibCell(LineItemTableViewCell.self, in: .module)
        tableView.register(SeparatorTableViewCell.self)
        tableView.register(CheckboxTableViewCell.self)
        tableView.register(TermsTableViewCell.self)
        tableView.register(LabelInfoTableViewCell.self)
        tableView.registerNibCell(ButtonsTableViewCell.self, in: .module)
    }

    private func setupNavigationBar() {
        switch presenter.navigationBarAppearance {
        case .custom(leading: let leading, trailing: let trailing, barStyle: let barStyle):
            set(
                barStyle: barStyle,
                leadingButtonStyle: leading,
                trailingButtonStyle: trailing
            )
        case .defaultDark:
            setStandardDarkContentStyle()
        case .defaultLight:
            setStandardLightContentStyle()
        case .hidden:
            setNavigationBar(visible: false)
        }
        presenter.titleView
            .distinctUntilChanged()
            .drive(onNext: { [weak self] titleView in
                self?.titleViewStyle = titleView
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override public func navigationBarLeadingButtonPressed() {
        switch presenter.navigationBarLeadingButtonAction {
        case .default:
            super.navigationBarLeadingButtonPressed()
        case .custom(let action):
            action()
        }
    }

    override public func navigationBarTrailingButtonPressed() {
        switch presenter.navigationBarTrailingButtonAction {
        case .default:
            super.navigationBarTrailingButtonPressed()
        case .custom(let action):
            action()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DetailsScreenViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        presenter.header(for: section)?
            .view(fittingWidth: view.bounds.width, customHeight: nil)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        presenter.header(for: section)?
            .defaultHeight ?? 0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idx = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        guard presenter.cells.indices.contains(idx) else {
            return
        }
        switch presenter.cells[indexPath.row] {
        case .numbered,
             .badges,
             .buttons,
             .label,
             .staticLabel,
             .interactableTextCell,
             .notice,
             .separator,
             .checkbox,
             .terms,
             .textField,
             .labelInfo:
            break
        case .lineItem(let presenter):
            presenter.tapRelay.accept(())
        }
    }

    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        assert(section == 0)
        return presenter.cells.count
    }

    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        assert(presenter.cells.indices.contains(indexPath.row))
        switch presenter.cells[indexPath.row] {
        case .numbered(let model):
            return numberedCell(for: indexPath, model: model)
        case .badges(let model):
            return badgesCell(for: indexPath, model: model)
        case .buttons(let models):
            return buttonsCell(for: indexPath, models: models)
        case .label(let presenter):
            return labelCell(for: indexPath, presenter: presenter)
        case .staticLabel(let viewModel):
            return staticLabelCell(for: indexPath, viewModel: viewModel)
        case .interactableTextCell(let viewModel):
            return interactableTextCell(for: indexPath, viewModel: viewModel)
        case .lineItem(let presenter):
            return lineItemCell(for: indexPath, presenter: presenter)
        case .notice(let viewModel):
            return noticeCell(for: indexPath, viewModel: viewModel)
        case .separator:
            return separatorCell(for: indexPath)
        case .textField(let viewModel):
            return textFieldCell(for: indexPath, viewModel: viewModel)
        case .checkbox(let viewModel):
            return checkBox(for: indexPath, model: viewModel)
        case .terms(let viewModel):
            return terms(for: indexPath, model: viewModel)
        case .labelInfo(let viewModel):
            return labelInfo(for: indexPath, model: viewModel)
        }
    }

    // MARK: - Accessors

    private func textFieldCell(for indexPath: IndexPath, viewModel: TextFieldViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(TextFieldTableViewCell.self, for: indexPath)
        cell.setup(
            viewModel: viewModel,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: scrollView
        )
        return cell
    }

    private func interactableTextCell(for indexPath: IndexPath, viewModel: InteractableTextViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(InteractableTextTableViewCell.self, for: indexPath)
        cell.contentInset = UIEdgeInsets(horizontal: 24, vertical: 0)
        cell.viewModel = viewModel
        return cell
    }

    private func numberedCell(for indexPath: IndexPath, model: BadgeNumberedItemViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(BadgeNumberedTableViewCell.self, for: indexPath)
        cell.viewModel = model
        return cell
    }

    private func checkBox(for indexPath: IndexPath, model: CheckboxViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(CheckboxTableViewCell.self, for: indexPath)
        cell.viewModel = model
        return cell
    }

    private func terms(for indexPath: IndexPath, model: TermsViewCellModel) -> UITableViewCell {
        let cell = tableView.dequeue(TermsTableViewCell.self, for: indexPath)
        cell.viewModel = model
        return cell
    }

    private func labelInfo(for indexPath: IndexPath, model: LabelInfoViewCellModel) -> UITableViewCell {
        let cell = tableView.dequeue(LabelInfoTableViewCell.self, for: indexPath)
        cell.viewModel = model
        return cell
    }

    private func separatorCell(for indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(SeparatorTableViewCell.self, for: indexPath)
    }

    private func lineItemCell(for indexPath: IndexPath, presenter: LineItemCellPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(LineItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func badgesCell(for indexPath: IndexPath, model: MultiBadgeViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(MultiBadgeTableViewCell.self, for: indexPath)
        cell.model = model
        return cell
    }

    private func buttonsCell(for indexPath: IndexPath, models: [ButtonViewModel]) -> UITableViewCell {
        let cell = tableView.dequeue(ButtonsTableViewCell.self, for: indexPath)
        cell.models = models
        return cell
    }

    private func staticLabelCell(for indexPath: IndexPath, viewModel: LabelContent) -> UITableViewCell {
        let cell = tableView.dequeue(LabelTableViewCell.self, for: indexPath)
        cell.content = viewModel
        return cell
    }

    private func labelCell(for indexPath: IndexPath, presenter: LabelContentPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(LabelTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func noticeCell(for indexPath: IndexPath, viewModel: NoticeViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(NoticeTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
}
