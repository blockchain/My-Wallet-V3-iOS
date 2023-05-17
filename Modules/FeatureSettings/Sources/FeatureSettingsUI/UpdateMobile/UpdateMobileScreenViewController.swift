// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class UpdateMobileScreenViewController: BaseScreenViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var updateButtonView: ButtonView!
    @IBOutlet private var continueButtonView: ButtonView!
    @IBOutlet private var disable2FALabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet fileprivate var badgeView: BadgeView!
    @IBOutlet private var mobileNumberTextFieldView: TextFieldView!

    // MARK: - Private Properties

    fileprivate var badgeShimmeringView: ShimmeringView!
    private var keyboardInteractionController: KeyboardInteractionController!
    private let presenter: UpdateMobileScreenPresenter
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        presenter: UpdateMobileScreenPresenter,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.presenter = presenter
        self.analyticsRecorder = analyticsRecorder
        super.init(nibName: UpdateMobileScreenViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .semantic.background
        shimmer()
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: .none
        )
        titleViewStyle = presenter.titleView
        keyboardInteractionController = KeyboardInteractionController(in: self)
        descriptionLabel.content = presenter.descriptionLabel
        mobileNumberTextFieldView.setup(
            viewModel: presenter.textFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        continueButtonView.viewModel = presenter.continueButtonViewModel
        updateButtonView.viewModel = presenter.updateButtonViewModel
        disable2FALabel.content = presenter.disable2FALabel

        mobileNumberTextFieldView.isEmpty
            ? analyticsRecorder.record(event: AnalyticsEvents.New.Settings.addMobileNumberClicked(origin: .settings))
            : analyticsRecorder.record(event: AnalyticsEvents.New.Settings.changeMobileNumberClicked)

        presenter.disable2FASMSVisibility
            .map(\.isHidden)
            .drive(disable2FALabel.rx.isHidden)
            .disposed(by: disposeBag)

        presenter.continueVisibility
            .map(\.isHidden)
            .drive(continueButtonView.rx.isHidden)
            .disposed(by: disposeBag)

        presenter.updateVisibility
            .map(\.isHidden)
            .drive(updateButtonView.rx.isHidden)
            .disposed(by: disposeBag)

        presenter.badgeState
            .bindAndCatch(to: rx.badgeViewModel)
            .disposed(by: disposeBag)
    }

    /// Should be called once when the parent view loads
    private func shimmer() {
        badgeShimmeringView = ShimmeringView(
            in: view,
            anchorView: badgeView,
            size: .init(width: 75, height: 24)
        )
    }
}

// MARK: - Rx

extension Reactive where Base: UpdateMobileScreenViewController {
    var badgeViewModel: Binder<BadgeAsset.State.BadgeItem.Presentation> {
        Binder(base) { view, state in
            let loading = {
                view.badgeShimmeringView.start()
            }

            switch state {
            case .loading:
                UIView.animate(withDuration: 0.5, animations: loading)
            case .loaded(next: let value):
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: .transitionCrossDissolve,
                    animations: {
                        view.badgeView.viewModel = value.viewModel
                        view.badgeShimmeringView.stop()
                    },
                    completion: nil
                )
            }
        }
    }
}
