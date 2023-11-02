// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Transitioning animator that supports view-controller custom animations
public class ScreenTransitioningAnimator: NSObject {

    // MARK: - Types

    public enum TransitionType {

        /// View controller is being pushed forward
        case pushIn(TimeInterval)

        /// View controller is being pushed from backward
        case pushOut(TimeInterval)

        /// Duration of the entire transition animation
        public var duration: TimeInterval {
            switch self {
            case .pushIn(let duration):
                duration
            case .pushOut(let duration):
                duration
            }
        }

        public static func translate(
            from navigationOperation: UINavigationController.Operation,
            duration: TimeInterval
        ) -> TransitionType {
            switch navigationOperation {
            case .push:
                .pushIn(duration)
            default:
                .pushOut(duration)
            }
        }
    }

    // MARK: - Properties

    public let transition: TransitionType

    // MARK: - Setup

    public init(transition: TransitionType) {
        self.transition = transition
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension ScreenTransitioningAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transition.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let originVC = transitionContext.viewController(forKey: .from) else { return }
        guard let originTransitioning = originVC as? NavigationTransitionAnimating else { return }

        guard let destinationVC = transitionContext.viewController(forKey: .to) else { return }
        guard let destinationTransitioning = destinationVC as? NavigationTransitionAnimating else { return }

        let container = transitionContext.containerView

        switch transition {
        case .pushIn:
            container.addSubview(destinationVC.view)
            destinationVC.view.frame = container.bounds
        case .pushOut:
            container.insertSubview(destinationVC.view, belowSubview: originVC.view)
        }

        let originAnimator = originTransitioning.disappearancePropertyAnimator(for: transition)
        destinationTransitioning.prepareForAppearance(for: transition)
        originAnimator.addCompletion { originPosition in
            guard originPosition == .end, !transitionContext.transitionWasCancelled else {
                transitionContext.completeTransition(false)
                return
            }
            let destinationAnimator = destinationTransitioning.appearancePropertyAnimator(for: self.transition)
            destinationAnimator.addCompletion { destinationPosition in
                let isComplete = destinationPosition == .end && !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(isComplete)
            }
            destinationAnimator.startAnimation()
        }
        originAnimator.startAnimation()
    }
}
