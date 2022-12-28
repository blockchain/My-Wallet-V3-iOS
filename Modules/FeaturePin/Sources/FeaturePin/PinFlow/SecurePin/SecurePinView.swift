// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class SecurePinView: UIView {

    // MARK: - UI Properties

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var pinViewsArray: [UIView]!

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - Injected

    var viewModel: SecurePinViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            titleLabel.textColor = viewModel.tint
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
        for (index, view) in pinViewsArray.enumerated() {
            view.accessibility = .id("\(AccessibilityIdentifiers.PinScreen.pinIndicatorFormat)\(index)")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pinViewsArray.forEach {
            $0.layer.cornerRadius = min($0.bounds.height, $0.bounds.width) * 0.5
        }
    }

    private func updatePin(to count: Int) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState],
            animations: {
                for (index, view) in self.pinViewsArray.enumerated() {
                    if index < count {
                        view.backgroundColor = self.viewModel.tint
                        view.transform = .identity
                    } else {
                        view.backgroundColor = self.viewModel.emptyPinColor
                        view.transform = CGAffineTransform(scaleX: self.viewModel.emptyScaleRatio, y: self.viewModel.emptyScaleRatio)
                    }
                }
            },
            completion: nil
        )
    }

    /// Returns the UIPropertyAnimator with jolt animation embedded witihin
    var joltAnimator: UIViewPropertyAnimator {
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
