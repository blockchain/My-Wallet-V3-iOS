// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

public class AlertView: UIView {

    // MARK: Private Static Properties

    fileprivate static let sheetBottomPadding: CGFloat = 16.0
    fileprivate static let titleTrailingPadding: CGFloat = 58.0
    fileprivate static let horizontalOffset: CGFloat = 32.0
    fileprivate static let horizontalPadding: CGFloat = 40.0
    fileprivate static let topToHeadingPadding: CGFloat = 40
    fileprivate static let messageToActionsPadding: CGFloat = 24.0
    fileprivate static let actionsToBottomPadding: CGFloat = 24.0
    fileprivate static let headlineToMessagePadding: CGFloat = 4.0
    fileprivate static let actionsVerticalPadding: CGFloat = 20.0
    fileprivate static let actionButtonHeight: CGFloat = 56.0
    fileprivate static let imageHeight: CGFloat = 72.0

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var notch: UIView!
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var topNote: UILabel!
    @IBOutlet fileprivate var headline: UILabel!
    @IBOutlet fileprivate var message: UILabel!
    @IBOutlet fileprivate var note: UILabel!
    @IBOutlet fileprivate var confirmButton: UIButton!
    @IBOutlet fileprivate var defaultButton: UIButton!
    @IBOutlet fileprivate var closeButton: UIButton!
    @IBOutlet fileprivate var headlineTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var defaultButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var okayButtonHeightConstraint: NSLayoutConstraint!

    fileprivate var observer: NSKeyValueObservation?
    fileprivate var model: AlertModel!
    fileprivate var completion: ((AlertAction) -> Void)?
    fileprivate var animator: UIDynamicAnimator!
    fileprivate var pushBehavior: UIPushBehavior!
    fileprivate var snapBehavior: UISnapBehavior!
    fileprivate var gravityBehavior: UIGravityBehavior!

    // MARK: Public Class Functions

    /// Note that the `completion` block is optional, however if you do provide
    /// a completion block, the action of type `.dismiss` will **always** be called
    /// assuming the user didn't tap one of the buttons.
    /// This is because users can swipe away the alert without actually selecting
    /// an action. Also, you shouldn't have to always provide an `AlertAction`
    /// of type `.dismiss`.
    public class func make(with model: AlertModel, completion: ((AlertAction) -> Void)?) -> AlertView {
        let nib = UINib(nibName: String(describing: AlertView.self), bundle: .module)
        let view = nib.instantiate(withOwner: self, options: nil).first as! AlertView
        view.model = model
        view.completion = completion
        return view
    }

    public class func estimatedHeight(for width: CGFloat, model: AlertModel) -> CGFloat {
        let adjustedWidth = width - horizontalPadding
        let imageViewHeight: CGFloat = model.image?.size.height ?? 0
        var headlineHeight: CGFloat = 0.0
        var messageHeight: CGFloat = 0.0
        var noteHeight: CGFloat = 0.0
        var topNoteHeight: CGFloat = 0.0
        var interItemPadding: CGFloat = 0.0
        var actionsHeight: CGFloat = 0.0

        if let value = model.headline {
            let attributed = NSAttributedString(
                string: value,
                attributes: [.font: headlineFont()]
            )
            let trailingPadding = model.style == .default ? titleTrailingPadding : 0.0
            headlineHeight = attributed.heightForWidth(width: adjustedWidth - trailingPadding)
        }
        if let value = model.body {
            let attributed = NSAttributedString(
                string: value,
                attributes: [.font: messageFont()]
            )
            messageHeight = attributed.heightForWidth(width: adjustedWidth)
        }
        if let value = model.note {
            let attributed = NSAttributedString(
                string: value,
                attributes: [.font: noteFont()]
            )
            noteHeight = attributed.heightForWidth(width: adjustedWidth)
        }
        if let value = model.topNote {
            let attributed = NSAttributedString(
                string: value,
                attributes: [.font: topNoteFont()]
            )
            topNoteHeight = attributed.heightForWidth(width: adjustedWidth)
        }

        if model.headline != nil, model.body != nil {
            interItemPadding += headlineToMessagePadding
        }
        if model.note != nil {
            interItemPadding += headlineToMessagePadding
        }
        if model.actions.count > 1 {
            interItemPadding += actionsVerticalPadding
        }
        /// A `.dismiss` action type is not a button but rather when the user
        /// swipes away the `AlertView` or taps outside of it.
        let actions = model.actions.filter { $0.style != .dismiss }
        actions.forEach { _ in actionsHeight += actionButtonHeight }
        let result = messageToActionsPadding +
            actionsToBottomPadding +
            topToHeadingPadding +
            actionsHeight +
            imageViewHeight +
            headlineHeight +
            messageHeight +
            noteHeight +
            topNoteHeight +
            interItemPadding
        return result
    }

    public class func headlineFont() -> UIFont {
        let font = Font(.branded(.montserratSemiBold), size: .custom(20.0))
        return font.result
    }

    public class func messageFont() -> UIFont {
        let font = Font(.branded(.montserratSemiBold), size: .custom(14.0))
        return font.result
    }

    public class func noteFont() -> UIFont {
        let font = Font(.branded(.montserratMedium), size: .custom(10.0))
        return font.result
    }

    public class func topNoteFont() -> UIFont {
        let font = Font(.branded(.montserratRegular), size: .custom(14))
        return font.result
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        apply(model: model)
    }

    public func registerForNotifications() {
        NotificationCenter.when(UIApplication.didEnterBackgroundNotification) { [weak self] _ in
            guard let self else { return }
            teardown()
        }
    }

    deinit {
        observer?.invalidate()
    }

    // MARK: Private

    fileprivate func apply(model: AlertModel) {
        if model.style == .sheet {
            notch.isHidden = model.dismissable == false
        }
        notch.layer.cornerRadius = 4
        headline.isHidden = model.headline == nil
        message.isHidden = model.body == nil
        note.isHidden = model.note == nil
        topNote.isHidden = model.topNote == nil
        headline.text = model.headline
        message.text = model.body
        note.text = model.note
        topNote.text = model.topNote
        if let image = model.image {
            imageView.image = image
            imageViewHeightConstraint.constant = image.size.height
            imageViewWidthConstraint.constant = image.size.width
        }
        if let imageTintColor = model.imageTintColor {
            imageView.tintColor = imageTintColor
        }

        confirmButton.isHidden = !model.actions.contains(where: { $0.style == .confirm($0.title ?? "") })

        defaultButton.isHidden = !model.actions.contains(where: { $0.style == .default($0.title ?? "") })

        if defaultButton.isHidden {
            defaultButtonHeightConstraint.constant = 0.0
        }

        if confirmButton.isHidden {
            okayButtonHeightConstraint.constant = 0.0
        }

        layer.cornerRadius = 8.0
        closeButton.tintColor = .gray4
        closeButton.isHidden = model.style == .sheet
        if closeButton.isHidden, headlineTrailingConstraint.isActive {
            NSLayoutConstraint.deactivate([headlineTrailingConstraint])
        }
        model.actions.forEach { action in
            switch action.style {
            case .confirm(let title):
                let font = Font(.branded(.montserratSemiBold), size: .custom(18.0)).result
                let attributedTitle = NSAttributedString(
                    string: title,
                    attributes: [
                        .font: font,
                        .foregroundColor: UIColor.white
                    ]
                )
                confirmButton.setAttributedTitle(attributedTitle, for: .normal)
            case .default(let title):
                let font = Font(.branded(.montserratSemiBold), size: .custom(18.0)).result
                let attributedTitle = NSAttributedString(
                    string: title,
                    attributes: [
                        .font: font,
                        .foregroundColor: UIColor.primaryButton
                    ]
                )
                defaultButton.setAttributedTitle(attributedTitle, for: .normal)
            case .dismiss:
                break
            }
        }
        [confirmButton, defaultButton].forEach { $0?.layer.cornerRadius = 4.0 }

        defaultButton.layer.borderColor = UIColor.primaryButton.cgColor
        defaultButton.layer.borderWidth = 1.0
        confirmButton.backgroundColor = .primaryButton

        if model.dismissable, model.style == .sheet {
            setupDynamicBehavior()
        }
    }

    fileprivate func teardown(with selectedAction: AlertAction? = nil) {
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
                    switch self.model.style {
                    case .default:
                        break
                    case .sheet:
                        guard let window = UIApplication.shared.firstKeyWindow else { return }
                        self.frame = self.frame.offsetBy(dx: 0.0, dy: window.bounds.maxY)
                    }
                })
            },
            completion: { [weak self] _ in
                guard let self else { return }
                dimmingView.removeFromSuperview()
                removeFromSuperview()
                if let action = selectedAction {
                    completion?(action)
                }
                observer?.invalidate()
            }
        )
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

    fileprivate func startAnimators(with velocity: CGPoint, offset: UIOffset) {
        guard animator.behaviors.contains(pushBehavior) == false else { return }
        pushBehavior.pushDirection = velocity.vector
        pushBehavior.setTargetOffsetFromCenter(offset, for: self)
        pushBehavior.magnitude = velocity.magnitude * 0.2
        animator.removeBehavior(snapBehavior)
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(pushBehavior)
        isUserInteractionEnabled = false
    }

    fileprivate func setupDynamicBehavior() {
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
                    if let dismiss = model.actions.filter({ $0.style == .dismiss }).first {
                        completion?(dismiss)
                    } else {
                        completion?(.defaultDismissal)
                    }
                    dimmingView.removeFromSuperview()
                    removeFromSuperview()
                    self.observer = nil
                }
            )
        }
    }

    @objc func dismiss() {
        guard model.dismissable == true else { return }
        if let dismiss = model.actions.first(where: { $0.style == .dismiss }) {
            teardown(with: dismiss)
        } else {
            teardown(with: .defaultDismissal)
        }
    }

    // MARK: Actions

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let confirm = model.actions.first(where: { $0.style == .confirm($0.title ?? "") }) else { return }
        teardown(with: confirm)
    }

    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        guard let action = model.actions.first(where: { $0.style == .default($0.title ?? "") }) else { return }
        teardown(with: action)
    }

    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        teardown()
    }

    // MARK: Public

    public func show() {
        guard let window = UIApplication.shared.firstKeyWindow else { return }

        /// You can only present one `AlertView` at a time
        guard window.subviews.contains(where: { $0 is AlertView }) == false else {
            print("You can only present one `AlertView` at a time.")
            return
        }
        switch model.style {
        case .default:
            presentDefaultView()
        case .sheet:
            presentSheetView()
        }
        registerForNotifications()
    }

    fileprivate func presentDefaultView() {
        guard let window = UIApplication.shared.firstKeyWindow else { return }
        alpha = 0.0
        let width = window.bounds.width - AlertView.horizontalOffset
        let height = AlertView.estimatedHeight(
            for: width,
            model: model
        )
        frame = CGRect(
            origin: frame.origin,
            size: .init(
                width: width,
                height: height
            )
        )
        center = window.center
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        window.addSubview(dimmingView)
        window.addSubview(self)

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
                })
            },
            completion: nil
        )
    }

    fileprivate func presentSheetView() {
        guard let window = UIApplication.shared.firstKeyWindow else { return }
        alpha = 0.0
        let width = window.bounds.width - AlertView.horizontalOffset
        let height = AlertView.estimatedHeight(
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
                        y: window.frame.maxY - height - AlertView.sheetBottomPadding
                    )
                })
            },
            completion: nil
        )
    }

    fileprivate lazy var dimmingView: UIView = {
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

    fileprivate lazy var dismissTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        return tap
    }()
}

extension CGPoint {
    var vector: CGVector {
        CGVector(dx: x, dy: y)
    }
}

extension CGPoint {
    var magnitude: CGFloat {
        sqrt(pow(x, 2) + pow(y, 2))
    }
}

extension UIApplication {

    public var firstKeyWindow: UIWindow? {
        windows.first(where: \.isKeyWindow)
    }
}
