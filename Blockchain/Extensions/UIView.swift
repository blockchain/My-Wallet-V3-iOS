//
//  UIView.swift
//  Blockchain
//
//  Created by Justin on 7/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func wiggle(withFeedback: Bool = true) {
        guard layer.animationKeys() == nil else { return }
        let wiggle = CABasicAnimation(keyPath: "position")
        wiggle.duration = 0.05
        wiggle.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        wiggle.repeatCount = 1
        wiggle.autoreverses = true
        wiggle.fromValue = CGPoint(
            x: center.x - 2.0,
            y: center.y
        )
        wiggle.toValue = CGPoint(
            x: center.x + 2.0,
            y: center.y
        )
        layer.add(wiggle, forKey: wiggle.keyPath)
        
        guard withFeedback else { return }
        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.error)
    }
}
