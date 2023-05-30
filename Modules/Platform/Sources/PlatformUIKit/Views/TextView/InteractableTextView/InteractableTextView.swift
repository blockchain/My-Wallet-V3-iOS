// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

/// This component implements an interactable text view that supports links.
/// It can be used to display terms of use / provacy policy linkable text
/// without any of the `UITextView` interaction side effects.
/// Only the embedded links are interactable while other content is ignored.
public final class InteractableTextView: UITextView {

    // MARK: - Injected

    public var viewModel: InteractableTextViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else { return }
            linkTextAttributes = [.foregroundColor: viewModel.linkStyle.color]
            viewModel.inputsRelay
                .map { inputs -> [NSAttributedString] in
                    inputs.map { input in
                        switch input {
                        case .text(string: let string):
                            return NSAttributedString(
                                string,
                                font: viewModel.textStyle.font,
                                color: viewModel.textStyle.color
                            )
                        case .url(string: let text, url: let url):
                            let link = NSMutableAttributedString(
                                text,
                                font: viewModel.linkStyle.font,
                                color: viewModel.linkStyle.color
                            )
                            link.makeHyperlink(to: url)
                            return link
                        }
                    }
                }
                .map { $0.join() }
                .map {
                    let mutableString = NSMutableAttributedString(attributedString: $0)
                    mutableString.add(lineSpacing: viewModel.lineSpacing)
                    mutableString.add(alignment: viewModel.alignment)
                    return mutableString
                }
                .bindAndCatch(to: rx.attributedText)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Accessors

    private var heightConstraint: NSLayoutConstraint!

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        isEditable = false
        dataDetectorTypes = .link
    }

    /// Setups the height according to the width
    public func setupHeight() {
        guard let attributedText else {
            return
        }
        let height = attributedText.heightForWidth(width: bounds.width)
        if let heightConstraint {
            heightConstraint.constant = height
        } else {
            heightConstraint = heightAnchor.constraint(equalToConstant: height)
            heightConstraint.isActive = true
        }
        layoutIfNeeded()
    }

    // MARK: - Behavior Modifiers

    /// Cannot become first responder its since content is predetermined by `viewModel`
    override public func becomeFirstResponder() -> Bool {
        false
    }

    /// Limits user interaction to links by identifying the closest position of touch,
    /// verifying it as a link position.
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard bounds.contains(point) else { return false }
        guard let position = closestPosition(to: point) else { return false }
        guard let range = tokenizer.rangeEnclosingPosition(
            position,
            with: .character,
            inDirection: .layout(.left)
        ) else { return false }
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }

    /// Accepts only tap gestures
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer is UITapGestureRecognizer
    }
}

// MARK: - UITextViewDelegate

extension InteractableTextView: UITextViewDelegate {

    // Makes sure only links are handled
    public func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        guard interaction == .invokeDefaultAction else { return false }
        let title = textView.attributedText.attributedSubstring(from: characterRange).string
        viewModel.tapRelay.accept(TitledLink(title: title, url: URL))
        return false
    }
}
