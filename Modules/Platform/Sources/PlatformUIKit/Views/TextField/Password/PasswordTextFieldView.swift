// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

public final class PasswordTextFieldView: TextFieldView {

    // MARK: - Exposed Properties

    private var viewModel: PasswordTextFieldViewModel!

    // MARK: - Private IBOutlets

    private let passwordStrengthIndicatorView = UIProgressView(progressViewStyle: .bar)

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    fileprivate var scoreViewTrailingConstraint: NSLayoutConstraint!

    // MARK: - Setup

    override func setup() {
        super.setup()
        setupPasswordStrengthIndicatorView()

        // *NOTE:* If `isSecureTextEntry` is set to `true`, and the text field regains focus.
        // After tapping a new value the text is entirely deleted and replaced with that new value.
        // Tapping the `Backspace` key just deletes the current value - resulting in an empty input field.
        // The problem is that when it happens `func textField(:_,shouldChangeCharactersIn:replacementString:) -> Bool`
        // does not not receive the correct range of characters and therefore we cannot calculate the replacement text,
        // and as consecuence we cannot show the currect score (Weak, Medium, Strong).
        // That is why we need to monitor `UITextField.textDidChangeNotification` as well and check the value AFTER
        // the change too.
        NotificationCenter.when(UITextField.textDidChangeNotification) { [weak self] _ in
            guard let self, isTextFieldFocused else { return }
            viewModel?.textFieldEdited(with: text)
        }
    }

    private func setupPasswordStrengthIndicatorView() {
        textFieldBackgroundView.addSubview(passwordStrengthIndicatorView)
        passwordStrengthIndicatorView.layoutToSuperview(.leading, .trailing)
        passwordStrengthIndicatorView.layoutToSuperview(.bottom, offset: -1)
        passwordStrengthIndicatorView.layout(dimension: .height, to: 1)
    }

    public func setup(
        viewModel: PasswordTextFieldViewModel,
        keyboardInteractionController: KeyboardInteractionController
    ) {
        super.setup(viewModel: viewModel, keyboardInteractionController: keyboardInteractionController)
        self.viewModel = viewModel

        // Bind score color to score label
        self.viewModel.score
            .map(\.color)
            .bindAndCatch(to: passwordStrengthIndicatorView.rx.fillColor)
            .disposed(by: disposeBag)

        // Bind score color to score label
        self.viewModel.score
            .map { Float($0.progress) }
            .bindAndCatch(to: passwordStrengthIndicatorView.rx.progress)
            .disposed(by: disposeBag)
    }
}
