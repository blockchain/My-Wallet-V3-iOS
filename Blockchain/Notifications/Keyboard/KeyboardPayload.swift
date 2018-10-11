//
//  KeyboardPayload.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

struct KeyboardPayload {
    let startingFrame: CGRect
    let endingFrame: CGRect
    let animationDuration: TimeInterval
    let animationCurve: UIView.AnimationCurve

    init(notification: Notification) {
        let payload = notification.userInfo
        startingFrame = payload?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        endingFrame = payload?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        animationDuration = payload?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        let value: NSNumber = payload?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber ?? .init(value: 7)
        animationCurve = UIView.AnimationCurve(rawValue: value.intValue) ?? .linear
    }
}
