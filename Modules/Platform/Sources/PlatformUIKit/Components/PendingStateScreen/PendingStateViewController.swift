// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import DIKit
import Errors
import ErrorsUI
import Localization
import RIBs
import RxCocoa
import RxSwift
import SwiftUI

public final class PendingStateViewController: BaseScreenViewController {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.PendingStateScreen

    // MARK: - Private IBOutlets

    private lazy var actionButton = ButtonView()
    private lazy var cancelButton = ButtonView()
    private lazy var titleLabel = UILabel()
    private lazy var subtitleTextView = InteractableTextView()
    private var compositeStatusView: CompositeStatusView!

    // MARK: - Properties

    private let presenter: PendingStatePresenterAPI & RibBridgePresenter
    private let disposeBag = DisposeBag()

    // MARK: - Init

    public required init(presenter: PendingStatePresenterAPI & RibBridgePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupAccessibility()
        presenter.viewModel
            .drive(rx.viewModel)
            .disposed(by: disposeBag)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }

    // MARK: - Setup

    private func setupAccessibility() {
        titleLabel.accessibility = .id(AccessibilityId.titleLabel)
        subtitleTextView.accessibility = .id(AccessibilityId.subtitleLabel)
        actionButton.accessibility = .id(AccessibilityId.button)
    }

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .darkContent())
    }

    private func setupUI() {
        view.backgroundColor = .white

        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleTextView.translatesAutoresizingMaskIntoConstraints = false
        let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleTextView])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = Spacing.inner
        view.addSubview(labelsStackView)

        labelsStackView.layoutToSuperview(.leading, relation: .equal, usesSafeAreaLayoutGuide: true, offset: Spacing.outer)
        labelsStackView.layoutToSuperview(.trailing, relation: .equal, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
        labelsStackView.layoutToSuperview(.centerX, relation: .equal)
        labelsStackView.layoutToSuperview(.centerY, relation: .equal)

        compositeStatusView = .init(
            edge: presenter.pendingStatusViewEdgeSize,
            mainContainerViewRatio: presenter.pendingStatusViewMainContainerViewRatio,
            sideContainerViewRatio: presenter.pendingStatusViewSideContainerRatio
        )
        view.addSubview(compositeStatusView)
        compositeStatusView.layout(edge: .bottom, to: .top, of: labelsStackView, relation: .equal, offset: -Spacing.outer)
        compositeStatusView.layoutToSuperview(.centerX)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView(arrangedSubviews: [cancelButton, actionButton])
        stackView.axis = .vertical
        stackView.spacing = Spacing.inner

        view.addSubview(stackView)
        stackView.layoutToSuperview(.centerX)
        stackView.layoutToSuperview(.leading, usesSafeAreaLayoutGuide: true, offset: Spacing.outer)
        stackView.layoutToSuperview(.trailing, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
        stackView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -Spacing.inner)

        actionButton.layout(dimension: .height, to: ButtonSize.Standard.height)
        cancelButton.layout(dimension: .height, to: ButtonSize.Standard.height)
    }

    // MARK: - View Update

    fileprivate func update(with model: PendingStateViewModel) {
        titleLabel.attributedText = model.title
        subtitleTextView.viewModel = model.subtitleTextViewModel
        compositeStatusView.currentTypeRelay.accept(model.compositeStatusViewType)
        if let buttonModel = model.button {
            actionButton.viewModel = buttonModel
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
        if let supplementaryButtonModel = model.supplementaryButton {
            cancelButton.viewModel = supplementaryButtonModel
            cancelButton.isHidden = false
        } else {
            cancelButton.isHidden = true
        }

        if model.displayCloseButton {
            trailingButtonStyle = .close
        } else {
            trailingButtonStyle = .none
        }
    }
}

// MARK: - Rx

extension Reactive where Base: PendingStateViewController {
    var viewModel: Binder<PendingStateViewModel> {
        Binder(base) { viewController, viewModel in
            viewController.update(with: viewModel)
        }
    }
}

public final class PendingStateViewUXErrorController: BaseScreenViewController {

    typealias L10n = LocalizationConstants.PendingCardStatusScreen.LoadingScreen

    private let app: AppProtocol
    private let presenter: PendingStatePresenterAPI & RibBridgePresenter

    private let disposeBag = DisposeBag()

    public required init(
        presenter: PendingStatePresenterAPI & RibBridgePresenter,
        app: AppProtocol = resolve()
    ) {
        self.presenter = presenter
        self.app = app
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }

    override public func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupNavigationBar()
        setupUI()
        presenter.error.drive(rx.error)
            .disposed(by: disposeBag)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        set(barStyle: .darkContent())
    }

    private func setupUI() {
        view.backgroundColor = .white
        embed {
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.blockchain)
                    .frame(width: 30.vw)
                    .aspectRatio(1, contentMode: .fit)
                VStack {
                    Text(L10n.title)
                        .typography(.title2)
                        .padding(.bottom, 8.pt)
                    Text(L10n.subtitle)
                        .typography(.paragraph2)
                }
                .padding()
                .foregroundColor(.semantic.title)
                Spacer()
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - View Update

    fileprivate var subscription: BlockchainEventSubscription?

    fileprivate func update(with error: UX.Error) {

        navigationControllerAPI?.pushViewController(
            UIHostingController(
                rootView: ErrorView(
                    ux: error,
                    dismiss: { [weak self] in
                        self?.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                    }
                )
                .app(app)
            ),
            animated: true
        )

        subscription = app.on(
            blockchain.ux.transaction.action.add.card,
            blockchain.ux.transaction.action.go.back.to.enter.amount
        ) { [weak self] _ in
            self?.navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
        .start()
    }
}

// MARK: - Rx

extension Reactive where Base: PendingStateViewUXErrorController {
    var error: Binder<UX.Error> {
        Binder(base) { viewController, error in
            viewController.update(with: error)
        }
    }
}
