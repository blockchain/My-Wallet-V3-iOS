//
//  TextFieldView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

/// A styled text field component with validation and password expression scoring
public class TextFieldView: UIView {

    /// Determines the top insert: title label to superview
    public var topInset: CGFloat = 16 {
        didSet {
            topInsetConstraint.constant = topInset
            layoutIfNeeded()
        }
    }
    
    public var bottomInset: CGFloat = 0 {
        didSet {
            bottomInsetConstraint.constant = bottomInset
            layoutIfNeeded()
        }
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
    
    @IBOutlet var textField: UITextField!
    @IBOutlet private(set) var textFieldBackgroundView: UIView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet private(set) var accessoryView: UIView!
    @IBOutlet private(set) var accessoryViewWidthConstraint: NSLayoutConstraint!
    
    private var keyboardInteractionController: KeyboardInteractionController!
    
    @IBOutlet private var topInsetConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomInsetConstraint: NSLayoutConstraint!
    
    private let button = UIButton()

    /// Scroll view container.
    /// To being the text field into focus when it becomes first responder
    private weak var scrollView: UIScrollView?
    
    // Mutable since we would like to make the text field
    // compatible with constructs like table/collection views
    private var disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private var viewModel: TextFieldViewModel!
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
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
        fromNib(named: TextFieldView.objectName)
        textField.textAlignment = .left
        titleLabel.font = .main(.medium, 12)
        titleLabel.textColor = .destructive
        titleLabel.verticalContentHuggingPriority = .required
        titleLabel.verticalContentCompressionResistancePriority = .required
        
        /// Cleanup the sensitive data if necessary
        NotificationCenter.when(UIApplication.didEnterBackgroundNotification) { [weak textField, weak viewModel] _ in
            guard let textField = textField else { return }
            guard let viewModel = viewModel else { return }
            if viewModel.type.requiresCleanupOnBackgroundState {
                textField.text = ""
                viewModel.textFieldEdited(with: "")
            }
        }
    }
    
    // MARK: - API
    
    /// Must be called by specialized subclasses
    public func setup(viewModel: TextFieldViewModel,
                      keyboardInteractionController: KeyboardInteractionController,
                      scrollView: UIScrollView? = nil) {
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
        textField.placeholder = nil
        titleLabel.font = viewModel.titleFont
        
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
            .observeOn(MainScheduler.instance)
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
            .map { $0.isOn }
            .drive(onNext: { [weak self] shouldGainFocus in
                guard let self = self else { return }
                if shouldGainFocus {
                    self.textFieldGainedFocus()
                } else {
                    self.textField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func textFieldGainedFocus() {
        textField.becomeFirstResponder()
        if let scrollView = scrollView {
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
                self.textFieldBackgroundView.layer.borderColor = mode.borderColor.cgColor
                self.textField.tintColor = mode.cursorColor
            },
            completion: nil)
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
                button.layoutToSuperview(.trailing, offset: -16)
                button.layoutToSuperview(axis: .vertical)
                
                badgeImageView.layoutToSuperview(.leading)
                badgeImageView.layoutToSuperview(.trailing, offset: -16)
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
    
    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
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
