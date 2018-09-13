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
    
    @IBInspectable var buttonTitleColor: UIColor = .brandPrimary {
        didSet {
            keypadButtons.forEach { button in
                button.setTitleColor(buttonTitleColor, for: .normal)
            }
        }
    }

    @IBAction func delimiterButtonTapped(_ sender: UIButton) {
        guard let titleLabel = sender.titleLabel, let value = titleLabel.text else { return }
        delegate?.onDelimiterTapped(value: value)
    }
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        guard let titleLabel = sender.titleLabel, let value = titleLabel.text else { return }
        delegate?.onAddInputTapped(value: value)
    }

    @IBAction func backspaceButtonTapped(_ sender: Any) {
        delegate?.onBackspaceTapped()
    }
}
