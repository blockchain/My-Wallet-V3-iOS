// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import UIKit

/// A styled text field component with validation and password expression scoring
public class TextFieldView: UIView {

    private static let defaultTopInset: CGFloat = 8
    private static let defaultBottomInset: CGFloat = 0

    /// Determines the top insert: title label to superview
    public var topInset: CGFloat = TextFieldView.defaultTopInset {
        didSet {
            topInsetConstraint.constant = topInset
            layoutIfNeeded()
        }
    }

    public var bottomInset: CGFloat = TextFieldView.defaultBottomInset {
        didSet {
            bottomInsetConstraint.constant = bottomInset
            layoutIfNeeded()
        }
    }

    public var isEmpty: Bool {
        textField.text?.isEmpty ?? true
    }

    /// Equals to the expression: `textField.text ?? ""`
    var text: String {
        textField.text ?? ""
    }

    /// Returns a boolean indicating whether the field is currently focused
    var isTextFieldFocused: Bool {
        textField.isFirstResponder
    }

    // MARK: - UI Properties

    let accessoryView = UIView()
    let textFieldBackgroundView = UIView()

    private let button = UIButton()
    private let textField = UITextField()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var bottomInsetConstraint: NSLayoutConstraint!
    private var topInsetConstraint: NSLayoutConstraint!
    private var subtitleLabelHeightConstraint: NSLayoutConstraint!
    private var subtitleLabelTopConstraint: NSLayoutConstraint!
    private var titleLabelHeightConstraint: NSLayoutConstraint!
    private var keyboardInteractionController: KeyboardInteractionController!

    /// Scroll view container.
    /// To being the text field into focus when it becomes first responder
    private weak var scrollView: UIScrollView?

    // Mutable since we would like to make the text field
    // compatible with constructs like table/collection views
    private var disposeBag = DisposeBag()

    // MARK: - Injected

    private var viewModel: TextFieldViewModel!

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Internal API

    /// Should be called once upon instantiation
    func setup() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(textFieldBackgroundView)
        addSubview(accessoryView)
        addSubview(button)
        addSubview(textField)

        textField.delegate = self

        titleLabelHeightConstraint = titleLabel.layout(dimension: .height, to: 24)
        titleLabel.layoutToSuperview(axis: .horizontal)
        topInsetConstraint = titleLabel.layoutToSuperview(.top, offset: Self.defaultTopInset)
        titleLabel.layout(
            edge: .bottom,
            to: .top,
            of: textFieldBackgroundView,
            priority: .penultimateHigh
        )

        textFieldBackgroundView.layoutToSuperview(axis: .horizontal)
        textFieldBackgroundView.layout(dimension: .height, to: 48)

        subtitleLabelHeightConstraint = subtitleLabel.layout(dimension: .height, to: 0)
        subtitleLabel.layoutToSuperview(axis: .horizontal)
        subtitleLabelTopConstraint = subtitleLabel.layout(
            edge: .top,
            to: .bottom,
            of: textFieldBackgroundView,
            offset: 0,
            priority: .penultimateHigh
        )
        bottomInsetConstraint = bottomAnchor
            .constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: Self.defaultBottomInset
            )

        textField.layout(edges: .leading, to: textFieldBackgroundView, offset: 16)
        textField.layout(edges: .bottom, .top, to: textFieldBackgroundView)
        textField.layout(edge: .trailing, to: .leading, of: accessoryView)

        textFieldBackgroundView.layout(edges: .trailing, to: accessoryView)
        textFieldBackgroundView.layout(edges: .centerY, to: accessoryView)
        accessoryView.layout(dimension: .height, to: 30, priority: .init(rawValue: 251))
        accessoryView.layout(dimension: .width, to: 0.5, priority: .defaultHigh)

        textField.textAlignment = .left
        titleLabel.font = .main(.medium, 12)
        titleLabel.textColor = .destructive
        titleLabel.verticalContentHuggingPriority = .required
        titleLabel.verticalContentCompressionResistancePriority = .required

        subtitleLabel.font = .main(.medium, 12)
        subtitleLabel.textColor = .destructive
        subtitleLabel.verticalContentHuggingPriority = .required
        subtitleLabel.verticalContentCompressionResistancePriority = .required
        subtitleLabel.numberOfLines = 0

        /// Cleanup the sensitive data if necessary
        NotificationCenter.when(UIApplication.didEnterBackgroundNotification) { [weak textField, weak viewModel] _ in
            guard let textField else { return }
            guard let viewModel else { return }
            if viewModel.type.requiresCleanupOnBackgroundState {
                textField.text = ""
                viewModel.textFieldEdited(with: "")
            }
        }
    }

    // MARK: - API

    /// Must be called by specialized subclasses
    public func setup(
        viewModel: TextFieldViewModel,
        keyboardInteractionController: KeyboardInteractionController,
        scrollView: UIScrollView? = nil
    ) {
        disposeBag = DisposeBag()
        self.scrollView = scrollView
        self.keyboardInteractionController = keyboardInteractionController
        self.viewModel = viewModel

        /// Set the accessibility property
        textField.accessibility = viewModel.accessibility

        textField.returnKeyType = viewModel.returnKeyType
        textField.inputAccessoryView = keyboardInteractionController.toolbar
        textField.autocorrectionType = viewModel.type.autocorrectionType
        textField.autocapitalizationType = viewModel.type.autocapitalizationType
        textField.font = viewModel.textFont
        textField.spellCheckingType = .no
        textField.placeholder = nil
        titleLabel.font = viewModel.titleFont
        subtitleLabel.font = viewModel.subtitleFont

        textFieldBackgroundView.clipsToBounds = true
        textFieldBackgroundView.backgroundColor = .clear
        textFieldBackgroundView.layer.cornerRadius = 8
        textFieldBackgroundView.layer.borderWidth = 1

        /// Bind `accessoryContentType`
        viewModel.accessoryContentType
            .bindAndCatch(to: rx.accessoryContentType)
            .disposed(by: disposeBag)

        /// Bind `isSecure`
        viewModel.isSecure
            .drive(textField.rx.isSecureTextEntry)
            .disposed(by: disposeBag)

        /// Bind `contentType`
        viewModel.contentType
            .drive(textField.rx.contentType)
            .disposed(by: disposeBag)

        /// Bind `keyboardType`
        viewModel.keyboardType
            .drive(textField.rx.keyboardType)
            .disposed(by: disposeBag)

        // Bind `placeholder`
        viewModel.placeholder
            .drive(textField.rx.placeholderAttributedText)
            .disposed(by: disposeBag)

        // Bind `textColor`
        viewModel.textColor
            .drive(textField.rx.textColor)
            .disposed(by: disposeBag)

        viewModel.backgroundColor
            .drive(textFieldBackgroundView.rx.backgroundColor)
            .disposed(by: disposeBag)

        // Take only the first value emitted by `text`
        viewModel.text
            .asObservable()
            .take(1)
            .bindAndCatch(to: textField.rx.text)
            .disposed(by: disposeBag)

        // Take all values emitted by `originalText`
        viewModel.originalText
            .compactMap { $0 }
            .bindAndCatch(to: textField.rx.text)
            .disposed(by: disposeBag)

        viewModel.mode
            .drive(rx.mode)
            .disposed(by: disposeBag)

        viewModel.isEnabled
            .bindAndCatch(to: textField.rx.isEnabled)
            .disposed(by: disposeBag)

        button.rx.tap
            .throttle(
                .milliseconds(200),
                latest: false,
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observe(on: MainScheduler.instance)
            .bindAndCatch(to: viewModel.tapRelay)
            .disposed(by: disposeBag)

        if viewModel.type == .newPassword || viewModel.type == .confirmNewPassword {
            textField.rx.text.orEmpty
                .bindAndCatch(weak: self) { [weak viewModel] (self, text) in
                    guard !self.textField.isFirstResponder else { return }
                    viewModel?.textFieldEdited(with: text)
                }
                .disposed(by: disposeBag)
        }

        viewModel.focus
            .map(\.isOn)
            .drive(onNext: { [weak self] shouldGainFocus in
                guard let self else { return }
                if shouldGainFocus {
                    textFieldGainedFocus()
                } else {
                    textField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }

    private func textFieldGainedFocus() {
        if let scrollView {
            let frameInScrollView = convert(frame, to: scrollView)
            scrollView.scrollRectToVisible(frameInScrollView, animated: true)
        }
    }

    fileprivate func set(mode: TextFieldViewModel.Mode) {
        UIView.transition(
            with: titleLabel,
            duration: 0.15,
            options: [.beginFromCurrentState, .transitionCrossDissolve],
            animations: {
                self.titleLabel.text = mode.title
                self.titleLabel.textColor = mode.titleColor
                self.titleLabelHeightConstraint.constant = mode.title.isEmpty ? 0 : 24

                self.subtitleLabel.text = mode.subtitle
                self.subtitleLabel.textColor = mode.titleColor
                self.subtitleLabelHeightConstraint.isActive = mode.subtitle.isEmpty
                self.subtitleLabelTopConstraint.constant = mode.subtitle.isEmpty ? 0 : 4

                self.textFieldBackgroundView.layer.borderColor = mode.borderColor.cgColor
                self.textField.tintColor = mode.cursorColor
            },
            completion: nil
        )
    }

    fileprivate func set(accessoryContentType: TextFieldViewModel.AccessoryContentType) {
        let resetAccessoryView = { [weak self] in
            self?.button.removeFromSuperview()
            self?.accessoryView.subviews.forEach { $0.removeFromSuperview() }
        }

        switch accessoryContentType {
        case .empty:
            resetAccessoryView()
        case .badgeImageView(let viewModel):
            if let badgeImageView = accessoryView.subviews.first as? BadgeImageView {
                badgeImageView.viewModel = viewModel
            } else {
                resetAccessoryView()
                let badgeImageView = BadgeImageView()
                badgeImageView.viewModel = viewModel
                accessoryView.addSubview(badgeImageView)
                accessoryView.addSubview(button)

                button.layoutToSuperview(.leading)
                button.layoutToSuperview(.trailing, offset: -8)
                button.layoutToSuperview(axis: .vertical)

                badgeImageView.layoutToSuperview(.leading)
                badgeImageView.layoutToSuperview(.trailing, offset: -8)
                badgeImageView.layoutToSuperview(axis: .vertical)
            }
        case .badgeLabel(let viewModel):
            if let badgeView = accessoryView.subviews.first as? BadgeView {
                badgeView.viewModel = viewModel
            } else {
                resetAccessoryView()
                let badgeView = BadgeView()
                badgeView.viewModel = viewModel
                accessoryView.addSubview(badgeView)
                badgeView.layoutToSuperview(.leading)
                badgeView.layoutToSuperview(.trailing, offset: -16)
                badgeView.layoutToSuperview(axis: .vertical)
            }
        }
    }
}

// MARK: UITextFieldDelegate

extension TextFieldView: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        viewModel.textFieldShouldBeginEditing()
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let text = textField.text ?? ""
        let input = (text as NSString).replacingCharacters(in: range, with: string)
        let operation: TextInputOperation = string.isEmpty ? .deletion : .addition
        let result = viewModel.editIfNecessary(input, operation: operation)
        switch result {
        case .formatted(to: let text):
            textField.text = text
            return false
        case .original:
            return true
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.textFieldShouldReturn()
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.textFieldDidEndEditing()
    }
}

// MARK: - Rx

extension Reactive where Base: TextFieldView {

    fileprivate var accessoryContentType: Binder<TextFieldViewModel.AccessoryContentType> {
        Binder(base) { view, contentType in
            view.set(accessoryContentType: contentType)
        }
    }

    /// Binder for the error handling
    fileprivate var mode: Binder<TextFieldViewModel.Mode> {
        Binder(base) { view, mode in
            view.set(mode: mode)
        }
    }
}
