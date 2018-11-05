//
//  BottomButtonContainerView.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a view that contains a CTA button at the bottom of it's view.
/// Conforming to this protocol will auto-adjust the CTA button whenever the keyboard
/// is presented/hidden.
protocol BottomButtonContainerView {
    
    /// This is to be set equal to the original bottom constraint
    /// set on the view pinning it to the bottom of it's parent. 
    var originalBottomButtonConstraint: CGFloat! { get set }
    
    /// Some screens may want to alter the offset of the
    /// view. This is normally set to `0` but can be set to
    /// any other value and it will be added to the keyboard's
    /// height.
    var optionalOffset: CGFloat { get set }

    var layoutConstraintBottomButton: NSLayoutConstraint! { get }
}

extension BottomButtonContainerView where Self: UIViewController {

    /// Sets up this view so that it can respond to keyboard show/hide events.
    /// This should be called in viewDidAppear()
    func setUpBottomButtonContainerView() {
        NotificationCenter.when(UIResponder.keyboardWillShowNotification) {
            self.keyboardWillShow(with: KeyboardPayload(notification: $0))
        }
        NotificationCenter.when(UIResponder.keyboardWillHideNotification) {
            self.keyboardWillHide(with: KeyboardPayload(notification: $0))
        }
    }

    /// Call this in deinit to remove the instance as an observer to the NotificationCenter
    func cleanUp() {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow(with payload: KeyboardPayload) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.animationDuration)
        UIView.setAnimationCurve(payload.animationCurve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint + payload.endingFrame.height + optionalOffset
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }

    func keyboardWillHide(with payload: KeyboardPayload) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.animationDuration)
        UIView.setAnimationCurve(payload.animationCurve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }
}
