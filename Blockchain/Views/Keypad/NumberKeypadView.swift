//
//  NumberKeypadView.swift
//  Blockchain
//
//  Created by kevinwu on 8/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// @objc is required for NumberKeypadViewDelegate property to be an IBOutlet
@objc protocol NumberKeypadViewDelegate: class {
    func onNumberButtonTapped(value: String)
    func onBackspaceTapped()
}

class NumberKeypadView: UIView {
    @IBOutlet weak var delegate: NumberKeypadViewDelegate?

    @IBOutlet var numberButtons: [UIButton]!

    @IBAction func numberButtonTapped(_ sender: UIButton) {
        guard let titleLabel = sender.titleLabel, let value = titleLabel.text else { return }
        delegate?.onNumberButtonTapped(value: value)
    }

    @IBAction func backspaceButtonTapped(_ sender: Any) {
        delegate?.onBackspaceTapped()
    }
}
