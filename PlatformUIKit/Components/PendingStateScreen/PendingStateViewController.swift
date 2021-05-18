//
//  PendingStateViewController.swift
//  PlatformUIKit
//
//  Created by Paulo on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

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

    public override func viewDidLoad() {
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
        titleLabel.accessibilityIdentifier = AccessibilityId.titleLabel
        subtitleTextView.accessibilityIdentifier = AccessibilityId.subtitleLabel
        actionButton.accessibilityIdentifier = AccessibilityId.button
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
        let stackView = UIStackView(arrangedSubviews: [actionButton, cancelButton])
        stackView.axis = .vertical
        stackView.spacing = Spacing.inner

        view.addSubview(stackView)
        stackView.layoutToSuperview(.centerX)
        stackView.layoutToSuperview(.leading, usesSafeAreaLayoutGuide: true, offset: Spacing.outer)
        stackView.layoutToSuperview(.trailing, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
        stackView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -Spacing.inner)

        actionButton.layout(dimension: .height, to: 48)
        cancelButton.layout(dimension: .height, to: 48)
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
