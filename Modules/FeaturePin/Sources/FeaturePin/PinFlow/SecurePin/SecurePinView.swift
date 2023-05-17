// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformUIKit
import RxCocoa
import RxSwift
import UIKitExtensions

final class SecurePinView: UIView {

    // MARK: - UI Properties

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!

    private var pinViews: [SecurePinNumberView] = {
        var pinViews = [SecurePinNumberView]()
        for i in 0...3 {
            let view = SecurePinNumberView()
            view.accessibility = .id("\(AccessibilityIdentifiers.PinScreen.pinIndicatorFormat)\(i)")
            pinViews.append(view)
        }
        return pinViews
    }()

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - Injected

    var viewModel: SecurePinViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            titleLabel.textColor = viewModel.tint
            titleLabel.font = .main(.semibold, 20)
            viewModel.fillCount.bind { [unowned self] count in
                self.updatePin(to: count)
            }
            .disposed(by: disposeBag)
        }
    }

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib(in: Bundle.module)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib(in: Bundle.module)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.accessibility = Accessibility(
            id: AccessibilityIdentifiers.PinScreen.pinSecureViewTitle,
            traits: .header
        )
        for pinView in pinViews {
            stackView.addArrangedSubview(pinView)
        }
    }

    private func updatePin(to count: Int) {
        let complete = count == pinViews.count
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState],
            animations: {
                for (index, view) in self.pinViews.enumerated() {
                    view.setFilled(index < count)
                    view.setSelected(index == count)
                    if complete {
                        view.setComplete()
                    }
                }
            },
            completion: nil
        )
    }

    /// Returns the UIPropertyAnimator with jolt animation embedded witihin
    var joltAnimator: UIViewPropertyAnimator {
        for view in pinViews {
            view.setFailed()
        }
        let duration: TimeInterval = 0.4
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.6)
        animator.addAnimations {
            self.transform = CGAffineTransform(translationX: 20, y: 0)
        }
        animator.addAnimations({
            self.transform = CGAffineTransform(translationX: -10, y: 0)
        }, delayFactor: CGFloat(duration) * 1.0 / 3.0)
        animator.addAnimations({
            self.transform = .identity
        }, delayFactor: CGFloat(duration) * 2.0 / 3.0)
        return animator
    }
}

final class SecurePinNumberView: UIView {

    var dot: UIView = {
        let view = UIView(frame: CGRect(x: 21, y: 21, width: 6, height: 6))
        view.backgroundColor = UIColor.semantic.title
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderColor = UIColor.semantic.light.cgColor
        layer.borderWidth = 1
        backgroundColor = UIColor.semantic.light
        dot.isHidden = true
        addSubview(dot)
        NSLayoutConstraint.activate(
            [
                widthAnchor.constraint(equalToConstant: 48),
                heightAnchor.constraint(equalToConstant: 48)
            ]
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.semantic.light.cgColor
        setNeedsDisplay()
    }

    func setFilled(_ filled: Bool) {
        dot.isHidden = !filled
    }

    func setSelected(_ selected: Bool) {
        layer.borderColor = selected ? UIColor.semantic.primary.cgColor : UIColor.clear.cgColor
    }

    func setComplete() {
        layer.borderColor = UIColor.semantic.success.cgColor
    }

    func setFailed() {
        layer.borderColor = UIColor.semantic.error.cgColor
    }
}
