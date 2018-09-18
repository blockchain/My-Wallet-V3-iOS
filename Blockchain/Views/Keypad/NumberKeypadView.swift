//
//  NumberKeypadView.swift
//  Blockchain
//
//  Created by kevinwu on 8/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol NumberKeypadViewDelegate: class {
    func onAddInputTapped(value: String)
    func onDelimiterTapped(value: String)
    func onBackspaceTapped()
}

@IBDesignable
class NumberKeypadView: NibBasedView {

    @IBOutlet var keypadButtons: [UIButton]!
    weak var delegate: NumberKeypadViewDelegate?
    fileprivate var feedback: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @IBInspectable var buttonTitleColor: UIColor = .brandPrimary {
        didSet {
            keypadButtons.forEach { button in
                button.setTitleColor(buttonTitleColor, for: .normal)
            }
        }
    }
    
    func updateKeypadVisibility(_ visibility: Visibility, animated: Bool = true) {
        guard let keypadButtons = keypadButtons else { return }
        guard keypadButtons.count > 0 else { return }
        
        if animated == false {
            keypadButtons.forEach({ $0.alpha = visibility.defaultAlpha })
            return
        }
        
        var buttons = keypadButtons
        let transform: CGAffineTransform = visibility == .hidden ? CGAffineTransform(scaleX: 0.01, y: 0.01) : .identity
        while buttons.count > 0 {
            guard let animatedButton = buttons.randomItem() else { return }
            buttons = buttons.filter({ $0.currentTitle != animatedButton.currentTitle })
            UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseIn, animations: {
                animatedButton.alpha = visibility.defaultAlpha
                animatedButton.transform = transform
            }, completion: nil)
        }
    }

    @IBAction func delimiterButtonTapped(_ sender: UIButton) {
        guard let titleLabel = sender.titleLabel, let value = titleLabel.text else { return }
        feedback.prepare()
        feedback.impactOccurred()
        delegate?.onDelimiterTapped(value: value)
    }
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        guard let titleLabel = sender.titleLabel, let value = titleLabel.text else { return }
        feedback.prepare()
        feedback.impactOccurred()
        delegate?.onAddInputTapped(value: value)
    }

    @IBAction func backspaceButtonTapped(_ sender: Any) {
        feedback.prepare()
        feedback.impactOccurred()
        delegate?.onBackspaceTapped()
    }
}
