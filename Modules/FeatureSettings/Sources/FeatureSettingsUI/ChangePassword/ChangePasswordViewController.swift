// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformUIKit

final class ChangePasswordViewController: BaseScreenViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var currentPasswordTextFieldView: TextFieldView!
    @IBOutlet private var newPasswordTextFieldView: PasswordTextFieldView!
    @IBOutlet private var confirmPasswordTextFieldView: PasswordTextFieldView!
    @IBOutlet private var updatePasswordButtonView: ButtonView!

    // MARK: - Injected

    private let presenter: ChangePasswordScreenPresenter

    // MARK: - Private Properties

    private var keyboardInteractionController: KeyboardInteractionController!

    // MARK: - Init

    init(presenter: ChangePasswordScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: ChangePasswordViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.background
        keyboardInteractionController = KeyboardInteractionController(in: self)
        descriptionLabel.content = presenter.descriptionContent
        updatePasswordButtonView.viewModel = presenter.buttonViewModel
        setupNavigationBar()
        setupTextFieldViews()
    }

    private func setupNavigationBar() {
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: .none
        )
        titleViewStyle = presenter.titleView
    }

    private func setupTextFieldViews() {
        currentPasswordTextFieldView.setup(
            viewModel: presenter.currentPasswordTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        newPasswordTextFieldView.setup(
            viewModel: presenter.passwordTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
        confirmPasswordTextFieldView.setup(
            viewModel: presenter.confirmPasswordTextFieldViewModel,
            keyboardInteractionController: keyboardInteractionController
        )
    }
}
