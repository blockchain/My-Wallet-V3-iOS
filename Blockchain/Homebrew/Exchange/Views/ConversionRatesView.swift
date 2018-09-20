//
//  ConversionRatesView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ConversionRatesView: NibBasedView {
    
    @IBOutlet fileprivate var baseToCounterLabel: UILabel!
    @IBOutlet fileprivate var baseToFiatLabel: UILabel!
    @IBOutlet fileprivate var counterToFiatLabel: UILabel!
    
    func updateVisibility(_ visibility: Visibility, animated: Bool) {
        guard let baseToCounter = baseToCounterLabel else { return }
        guard let baseToFiat = baseToFiatLabel else { return }
        guard let counterToFiat = counterToFiatLabel else { return }
        var labels = [baseToCounter, baseToFiat, counterToFiat]
        if animated == false {
            labels.forEach({ $0.alpha = visibility.defaultAlpha })
            alpha = visibility.defaultAlpha
            return
        }
        
        while labels.count > 0 {
            guard let candidate = labels.randomItem() else { return }
            labels = labels.filter({ $0.text != candidate.text })
            
            UIView.animate(withDuration: 0.2, delay: 0.05, options: [.curveEaseIn, .transitionCrossDissolve], animations: {
                candidate.alpha = visibility.defaultAlpha
            }, completion: nil)
        }
        alpha = visibility.defaultAlpha
    }
    
    func apply(baseToCounter: String, baseToFiat: String, counterToFiat: String) {
        baseToCounterLabel.text = baseToCounter
        baseToFiatLabel.text = baseToFiat
        counterToFiatLabel.text = counterToFiat
    }
}
