//
//  NumberKeypadView.swift
//  Blockchain
//
//  Created by kevinwu on 8/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol NumberKeypadViewDelegate: class {
    func onNumberButtonTapped(value: String)
    func onDecimalButtonTapped()
    func onBackspaceTapped()
}

@IBDesignable
class NumberKeypadView: NibBasedView {

    weak var delegate: NumberKeypadViewDelegate?

    @IBAction func numberButtonTapped(_ sender: UIButton) {
        guard let titleLabel = sender.titleLabel, let value = titleLabel.text else { return }
        delegate?.onNumberButtonTapped(value: value)
    }

    @IBAction func decimalButtonTapped(_ sender: Any) {
        delegate?.onDecimalButtonTapped()
    }

    @IBAction func backspaceButtonTapped(_ sender: Any) {
        delegate?.onBackspaceTapped()
    }
}
