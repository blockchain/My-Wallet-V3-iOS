// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxCocoa
import RxSwift
import UIKit

/// The standard wallet button.
/// Typically located at the bottom of a context, used as primary / secondary CTA buttons.
/// - see also: [ButtonViewModel](x-source-tag://ButtonViewModel).
public final class ButtonView: UIView {

    // MARK: - UI Properties

    private let button = UIButton(type: .system)
    private let imageView = UIImageView(image: nil)
    private let label = UILabel(frame: .zero)

    // Constraints for scenario with title only, and no image
    private var labelToImageViewLeadingConstraint: NSLayoutConstraint!
    private var labelToSuperviewLeadingConstraint: NSLayoutConstraint!
    private var labelToSuperviewBottomConstraint: NSLayoutConstraint!
    private var labelToSuperviewTopConstraint: NSLayoutConstraint!
    private var labelToSuperviewTrailingConstraint: NSLayoutConstraint!

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: - Dependencies

    public var viewModel: ButtonViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else {
                button.isEnabled = false
                label.text = nil
                imageView.image = nil
                return
            }

            // Set non-reactive properties
            label.font = viewModel.font

            // Set accessibility
            accessibility = viewModel.accessibility

            // Bind background color
            viewModel.backgroundColor
                .drive(rx.backgroundColor)
                .disposed(by: disposeBag)

            // Bind border color
            viewModel.borderColor
                .drive(layer.rx.borderColor)
                .disposed(by: disposeBag)

            // bind label color
            viewModel.contentColor
                .drive(label.rx.textColor)
                .disposed(by: disposeBag)

            // Bind label text color
            viewModel.text
                .drive(label.rx.text)
                .disposed(by: disposeBag)

            // Bind image view tint color
            viewModel.contentColor
                .drive(imageView.rx.tintColor)
                .disposed(by: disposeBag)

            // Bind image view's image
            viewModel.image
                .drive(imageView.rx.image)
                .disposed(by: disposeBag)

            // Bind view model enabled indication to button
            viewModel.isEnabled
                .drive(button.rx.isEnabled)
                .disposed(by: disposeBag)

            // Bind opacity
            viewModel.alpha
                .drive(rx.alpha)
                .disposed(by: disposeBag)

            // bind contains image
            viewModel.containsImage
                .bind { [weak self] containsImage in
                    guard let self else { return }
                    if containsImage {
                        label.textAlignment = .natural
                        labelToImageViewLeadingConstraint.priority = .penultimateHigh
                        labelToSuperviewLeadingConstraint.priority = .penultimateLow
                    } else {
                        label.textAlignment = .center
                        labelToImageViewLeadingConstraint.priority = .penultimateLow
                        labelToSuperviewLeadingConstraint.priority = .penultimateHigh
                    }
                    layoutIfNeeded()
                }
                .disposed(by: disposeBag)

            // Bind button taps
            button.rx.tap
                .throttle(
                    .milliseconds(200),
                    latest: false,
                    scheduler: MainScheduler.asyncInstance
                )
                .bindAndCatch(to: viewModel.tapRelay)
                .disposed(by: disposeBag)

            viewModel.contentInset
                .drive(onNext: { [weak self] contentInset in
                    self?.updateContentInset(to: contentInset)
                })
                .disposed(by: disposeBag)
        }
    }

    private func updateContentInset(to contentInset: UIEdgeInsets) {
        labelToSuperviewLeadingConstraint.constant = contentInset.left
        labelToSuperviewBottomConstraint.constant = -contentInset.bottom
        labelToSuperviewTopConstraint.constant = contentInset.top
        labelToSuperviewTrailingConstraint.constant = -contentInset.right
        layoutIfNeeded()
    }

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        layer.borderWidth = 1

        addSubview(imageView)
        addSubview(button)
        addSubview(label)

        // Button
        button.layoutToSuperview(.leading, .trailing, .top, .bottom)
        button.addTargetForTouchUp(self, selector: #selector(touchUp))
        button.addTargetForTouchDown(self, selector: #selector(touchDown))

        // ImageView
        imageView.contentMode = .left
        imageView.layoutToSuperview(.top, .bottom)
        imageView.layoutToSuperview(.leading, offset: 16)
        imageView.layout(edge: .trailing, to: .centerX, of: self, relation: .equal, offset: -10, priority: .penultimateHigh)

        // Label
        label.numberOfLines = 0
        labelToSuperviewLeadingConstraint = label.layoutToSuperview(.leading, priority: .penultimateHigh)
        labelToSuperviewTrailingConstraint = label.layoutToSuperview(.trailing)
        labelToSuperviewTopConstraint = label.layoutToSuperview(.top)
        labelToSuperviewBottomConstraint = label.layoutToSuperview(.bottom)
        labelToImageViewLeadingConstraint = label.layout(edge: .leading, to: .trailing, of: imageView, priority: .penultimateLow)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = ButtonSize.Standard.cornerRadius(
            height: frame.height
        )
    }

    // MARK: - User Interactions

    @objc private func touchUp() {
        alpha = 1
    }

    @objc private func touchDown() {
        alpha = 0.85
    }
}

extension Reactive where Base: ButtonView {
    public var viewModel: Binder<ButtonViewModel> {
        Binder(base) { buttonView, viewModel in
            buttonView.viewModel = viewModel
        }
    }
}
