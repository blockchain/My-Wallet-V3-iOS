// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import DIKit
import ErrorsUI
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import SwiftUI

final class PendingTransactionViewController: BaseScreenViewController, PendingTransactionPagePresentable {

    // MARK: - Private Properties

    private let closeTriggered = PublishSubject<Void>()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let primaryButton = ButtonView()
    private let secondaryButton = ButtonView()
    private let disposeBag = DisposeBag()
    private let compositeStatusView = CompositeStatusView(edge: 72.0)

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(Color.semantic.light)

        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0

        view.addSubview(stackView)
        view.addSubview(compositeStatusView)

        stackView.axis = .vertical
        stackView.layoutToSuperviewCenter()
        stackView.layout(to: .leading, of: view, offset: 16.0)
        stackView.layout(to: .trailing, of: view, offset: -16.0)
        compositeStatusView.layout(edge: .centerX, to: .centerX, of: stackView)
        compositeStatusView.layout(edge: .bottom, to: .top, of: stackView, offset: -24)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.spacing = 16.0

        let buttonsContainer = UIStackView(arrangedSubviews: [secondaryButton, primaryButton])
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 16.0

        view.addSubview(buttonsContainer)

        primaryButton.layout(dimension: .height, to: ButtonSize.Standard.height)
        secondaryButton.layout(dimension: .height, to: ButtonSize.Standard.height)

        buttonsContainer.layout(to: .bottomMargin, of: view, offset: -16.0)
        buttonsContainer.layout(to: .leading, of: view, offset: 16.0)
        buttonsContainer.layout(to: .trailing, of: view, offset: -16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .none
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close
        )
    }

    // MARK: - PendingTransactionPagePresentable

    func connect(state: Driver<PendingTransactionPageState>) -> Driver<PendingTransactionPageState.Effect> {
        state
            .map(\.title)
            .drive(titleLabel.rx.content)
            .disposed(by: disposeBag)

        state
            .map(\.subtitle)
            .drive(subtitleLabel.rx.content)
            .disposed(by: disposeBag)

        state
            .map(\.compositeViewType)
            .drive(compositeStatusView.currentTypeRelay)
            .disposed(by: disposeBag)

        state
            .map(\.primaryButtonViewModelVisibility)
            .map(\.defaultAlpha)
            .drive(primaryButton.rx.alpha)
            .disposed(by: disposeBag)

        state
            .map(\.secondaryButtonViewModelVisibility)
            .map(\.defaultAlpha)
            .drive(secondaryButton.rx.alpha)
            .disposed(by: disposeBag)

        state
            .compactMap(\.primaryButtonViewModel)
            .drive(primaryButton.rx.viewModel)
            .disposed(by: disposeBag)

        state
            .compactMap(\.secondaryButtonViewModel)
            .drive(secondaryButton.rx.viewModel)
            .disposed(by: disposeBag)

        let closeTapped = closeTriggered
            .map { PendingTransactionPageState.Effect.close }

        let primaryButtonTapped = state
            .compactMap(\.primaryButtonViewModel)
            .flatMap(\.tap)
            .flatMap { state.map(\.effect) }
            .asObservable()

        let secondaryButtonTapped = state
            .compactMap(\.secondaryButtonViewModel)
            .flatMap(\.tap)
            .map { PendingTransactionPageState.Effect.close }
            .asObservable()

        return Observable
            .merge(closeTapped, primaryButtonTapped, secondaryButtonTapped)
            .asDriver(onErrorJustReturn: .close)
    }

    // MARK: - Navigation

    override func navigationBarTrailingButtonPressed() {
        closeTriggered.onNext(())
    }
}
