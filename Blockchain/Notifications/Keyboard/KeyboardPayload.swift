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
    let animationCurve: UIViewAnimationCurve

    init(notification: Notification) {
        let payload = notification.userInfo
        startingFrame = payload?[UIKeyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        endingFrame = payload?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        animationDuration = payload?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        let value: NSNumber = payload?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber ?? .init(value: 7)
        animationCurve = UIViewAnimationCurve(rawValue: value.intValue) ?? .linear
    }
}
