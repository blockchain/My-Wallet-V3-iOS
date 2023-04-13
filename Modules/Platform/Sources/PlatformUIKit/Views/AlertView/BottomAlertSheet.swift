// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

public enum BottomAlertType {
    case image(UIImage)
    case loading
}

public protocol BottomAlertModel {
    var title: String { get }
    var subtitle: String { get }
    var gradient: Gradient { get }
    var dismissable: Bool { get }
}

public struct LoadingBottomAlert: BottomAlertModel {
    public var title: String
    public var subtitle: String
    public var gradient: Gradient
    public var dismissable: Bool {
        false
    }

    public init(title: String, subtitle: String, gradient: Gradient) {
        self.title = title
        self.subtitle = subtitle
        self.gradient = gradient
    }
}

public struct ThumbnailBottomAlert: BottomAlertModel {
    public var title: String
    public var subtitle: String
    public var gradient: Gradient
    public var dismissable: Bool
    public let thumbnail: UIImage

    public init(title: String, subtitle: String, gradient: Gradient, dismissable: Bool = true, thumbnail: UIImage) {
        self.title = title
        self.subtitle = subtitle
        self.gradient = gradient
        self.dismissable = dismissable
        self.thumbnail = thumbnail
    }
}

public class BottomAlertSheet: UIView {

    public typealias Model = BottomAlertModel

    private static let sheetBottomPadding: CGFloat = 16.0
    private static let horizontalOffset: CGFloat = 32.0
    private static let horizontalPadding: CGFloat = 40.0
    private static let thumbnailToTitlePadding: CGFloat = 32.0
    private static let interItemPadding: CGFloat = 8.0
    private static let bottomPadding: CGFloat = 72.0
    private static let topPadding: CGFloat = 72.0
    private static let containerHeight: CGFloat = 54.0

    @IBOutlet private var gradientView: GradientView!
    @IBOutlet private var thumbnail: UIImageView!
    @IBOutlet private var loadingContainer: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!

    private let loadingViewPresenter: LoadingViewPresenting = resolve()
    private var model: Model!
    private var observer: NSKeyValueObservation?
    private var animator: UIDynamicAnimator!
    private var pushBehavior: UIPushBehavior!
    private var snapBehavior: UISnapBehavior!
    private var gravityBehavior: UIGravityBehavior!

    public class func make(with model: Model) -> BottomAlertSheet {
        let nib = UINib(nibName: String(describing: BottomAlertSheet.self), bundle: .module)
        let view = nib.instantiate(withOwner: self, options: nil).first as! BottomAlertSheet
        view.model = model
        return view
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        apply(model: model)
    }

    private func apply(model: Model) {
        if model is LoadingBottomAlert {
            loadingViewPresenter.showCircular(in: loadingContainer, with: nil)
        }

        if let thumbnailModel = model as? ThumbnailBottomAlert {
            thumbnail.image = thumbnailModel.thumbnail
        }

        gradientView.startColor = model.gradient.startColor
        gradientView.endColor = model.gradient.endColor
        title.text = model.title
        subtitle.text = model.subtitle
        if model.dismissable {
            setupDynamicBehavior()
        }
    }

    public class func estimatedHeight(for width: CGFloat, model: Model) -> CGFloat {
        let adjustedWidth = width - horizontalPadding

        let titleHeight = NSAttributedString(
            string: model.title,
            attributes: [
                .font: titleFont()
            ]
        ).heightForWidth(width: adjustedWidth)

        let subtitleHeight = NSAttributedString(
            string: model.subtitle,
            attributes: [
                .font: subtitleFont()
            ]
        ).heightForWidth(width: adjustedWidth)

        return topPadding +
            bottomPadding +
            titleHeight +
            subtitleHeight +
            containerHeight +
            interItemPadding +
            thumbnailToTitlePadding
    }

    public func show() {
        presentSheetView()
        registerForNotifications()
    }

    public func registerForNotifications() {
        NotificationCenter.when(UIApplication.didEnterBackgroundNotification) { [weak self] _ in
            guard let self else { return }
            hide()
        }
    }

    public func hide() {
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0.0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1, animations: {
                    self.alpha = 0.0
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2, animations: {
                    self.dimmingView.alpha = 0.0
                    guard let window = UIApplication.shared.firstKeyWindow else { return }
                    self.frame = self.frame.offsetBy(dx: 0.0, dy: window.bounds.maxY)
                })
            },
            completion: { [weak self] _ in
                guard let self else { return }
                dimmingView.removeFromSuperview()
                removeFromSuperview()
            }
        )
    }

    public class func titleFont() -> UIFont {
        let font = Font(.branded(.montserratMedium), size: .custom(24.0))
        return font.result
    }

    public class func subtitleFont() -> UIFont {
        let font = Font(.branded(.montserratMedium), size: .custom(16.0))
        return font.result
    }

    private func startAnimators(with velocity: CGPoint, offset: UIOffset) {
        guard animator.behaviors.contains(pushBehavior) == false else { return }
        pushBehavior.pushDirection = velocity.vector
        pushBehavior.setTargetOffsetFromCenter(offset, for: self)
        pushBehavior.magnitude = velocity.magnitude * 0.2
        animator.removeBehavior(snapBehavior)
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(pushBehavior)
        isUserInteractionEnabled = false
    }

    private func setupDynamicBehavior() {
        guard animator == nil else { return }
        guard let window = UIApplication.shared.firstKeyWindow else { return }

        animator = UIDynamicAnimator(referenceView: window)
        snapBehavior = UISnapBehavior(
            item: self,
            snapTo: center
        )
        gravityBehavior = UIGravityBehavior(items: [self])
        gravityBehavior.magnitude = 10
        pushBehavior = UIPushBehavior(items: [self], mode: .instantaneous)
        animator.addBehavior(snapBehavior)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pannedView(panGestureRecognizer:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(panGesture)
    }

    private func presentSheetView() {
        guard let window = UIApplication.shared.firstKeyWindow else { return }
        alpha = 0.0
        let width = window.bounds.width - BottomAlertSheet.horizontalOffset
        let height = BottomAlertSheet.estimatedHeight(
            for: width,
            model: model
        )
        let start = CGPoint(
            x: window.bounds.midX - (width / 2.0),
            y: window.bounds.maxY
        )
        frame = CGRect(
            origin: start,
            size: .init(
                width: width,
                height: height
            )
        )
        window.addSubview(dimmingView)
        window.addSubview(self)

        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animateKeyframes(
            withDuration: 0.4,
            delay: 0.0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                    self.dimmingView.alpha = 0.4
                })
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2, animations: {
                    self.alpha = 1.0
                    self.transform = .identity
                    self.frame.origin = CGPoint(
                        x: self.frame.origin.x,
                        y: window.frame.maxY - height - BottomAlertSheet.sheetBottomPadding
                    )
                })
            },
            completion: nil
        )
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            observeCenter()
        } else {
            observer?.invalidate()
        }
    }

    private func observeCenter() {
        guard observer == nil else {
            return
        }
        observer?.invalidate()
        observer = observe(\.center, options: [.new]) { [weak self] _, change in
            guard let self else { return }
            guard let point = change.newValue else { return }
            guard UIScreen.main.bounds.contains(point) == false else { return }
            guard let superview else { return }
            guard superview.subviews.contains(dimmingView) else { return }
            UIView.animate(
                withDuration: 0.5,
                animations: { [weak self] in
                    guard let self else { return }
                    alpha = 0.0
                    dimmingView.alpha = 0.0
                },
                completion: { [weak self] _ in
                    guard let self else { return }
                    guard let observer else {
                        return
                    }
                    observer.invalidate()
                    dimmingView.removeFromSuperview()
                    removeFromSuperview()
                    self.observer = nil
                }
            )
        }
    }

    @objc func pannedView(panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            animator.removeBehavior(snapBehavior)
        case .changed:
            let translation = panGestureRecognizer.translation(in: self)
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            panGestureRecognizer.setTranslation(.zero, in: self)
            let location = panGestureRecognizer.location(in: superview)
            let offset = UIOffset(horizontal: location.x - center.x, vertical: location.y - center.y)
            let velocity = panGestureRecognizer.velocity(in: self)
            if velocity.magnitude > 1000 {
                startAnimators(with: velocity, offset: offset)
            }
        case .ended, .cancelled, .failed:
            guard animator.behaviors.contains(pushBehavior) == false else { return }
            animator.addBehavior(snapBehavior)
        case .possible:
            break
        @unknown default:
            break
        }
    }

    @objc func dismiss() {
        guard model.dismissable == true else { return }
        hide()
    }

    private lazy var dimmingView: UIView = {
        let dimming = UIView(frame: UIScreen.main.bounds)
        dimming.backgroundColor = .black
        dimming.alpha = 0.0
        dimming.isAccessibilityElement = true
        dimming.accessibilityTraits = .button
        dimming.accessibilityHint = NSLocalizedString(
            "Double tap to close",
            comment: "Dimmed background behind a modal alert. Double tap to close."
        )
        dimming.isUserInteractionEnabled = true
        dimming.addGestureRecognizer(dismissTapGesture)
        return dimming
    }()

    private lazy var dismissTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        return tap
    }()
}
