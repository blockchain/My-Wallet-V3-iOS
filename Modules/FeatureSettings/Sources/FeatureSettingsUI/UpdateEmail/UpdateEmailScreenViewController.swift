// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class UpdateEmailScreenViewController: BaseScreenViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var resendButtonView: ButtonView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var emailTextFieldView: TextFieldView!
    @IBOutlet fileprivate var badgeView: BadgeView!
    @IBOutlet private var updateButtonView: ButtonView!

    // MARK: - Private Properties

    fileprivate var badgeShimmeringView: ShimmeringView!
    private var keyboardInteractionController: KeyboardInteractionController!
    private let presenter: UpdateEmailScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(presenter: UpdateEmailScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: UpdateEmailScreenViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .semantic.background
        shimmer()
        titleViewStyle = presenter.titleView
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: .none
        )
        keyboardInteractionController = KeyboardInteractionController(in: self)
        descriptionLabel.content = presenter.descriptionContent
        updateButtonView.viewModel = presenter.updateButtonViewModel
        resendButtonView.viewModel = presenter.resendButtonViewModel
        emailTextFieldView.setup(viewModel: presenter.textField, keyboardInteractionController: keyboardInteractionController)

        presenter.resendVisibility
            .map(\.isHidden)
            .drive(resendButtonView.rx.isHidden)
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
    }
}

// MARK: - Rx

extension Reactive where Base: UpdateEmailScreenViewController {
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
