// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa

final class PulseContainerView: PassthroughView {

    // MARK: Rx

    var selection: Signal<Void> {
        selectionRelay.asSignal()
    }

    private let selectionRelay = PublishRelay<Void>()

    // MARK: - Properties

    private let max: CGRect = .init(origin: .zero, size: .init(width: 32.0, height: 32.0))

    private lazy var pulseAnimationView: PulseAnimationView = {
        let animationView = PulseAnimationView(
            diameter: self.frame.min(max).width
        )
        return animationView
    }()

    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private lazy var button: UIButton = {
        let button = UIButton(frame: max)
        button.addTarget(self, action: #selector(containerTapped(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Setup

    init() {
        super.init(frame: UIScreen.main.bounds)

        addSubview(button)
        addSubview(pulseAnimationView)
        button.layoutToSuperviewCenter()
        pulseAnimationView.layoutToSuperviewCenter()
        pulseAnimationView.layout(size: CGSize(width: frame.min(max).width, height: frame.min(max).height))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Selection

    @objc private func containerTapped(_ sender: UIButton) {
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        selectionRelay.accept(())
    }
}

// MARK: - PulseContainerViewProtocol

extension PulseContainerView: PulseContainerViewProtocol {
    func animate() {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
        animator.addAnimations {
            self.alpha = Visibility.visible.defaultAlpha
        }
        animator.addAnimations({
            self.pulseAnimationView.animate()
        }, delayFactor: 0.1)
        animator.startAnimation()
    }

    func fadeOut() {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn)
        animator.addAnimations {
            let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.pulseAnimationView.transform = scale
        }
        animator.addAnimations({
            self.alpha = Visibility.hidden.defaultAlpha
        }, delayFactor: 0.1)
        animator.addCompletion { _ in
            self.removeFromSuperview()
        }
        animator.startAnimation()
    }
}
