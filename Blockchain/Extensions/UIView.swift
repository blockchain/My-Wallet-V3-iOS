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
    
    func wiggle(duration: CFTimeInterval = 0.8) {
        guard layer.animationKeys() == nil else { return }
        
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        translation.values = [-10, 10, -10, 10, -5, 5, -5, 5, -3, 3, -2, 2, 0]
        translation.duration = duration
        
        self.layer.add(translation, forKey: translation.keyPath)
    }
}
