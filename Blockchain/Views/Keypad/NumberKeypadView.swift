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
    func onBackspaceTapped()
}

@IBDesignable
class NumberKeypadView: NibBasedView {

    @IBOutlet var keypadButtons: [UIButton]!
    weak var delegate: NumberKeypadViewDelegate?

    override func awakeFromNib() {
        keypadButtons.forEach { button in
            button.setTitleColor(UIColor.brandPrimary, for: .normal)
            button.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraLarge)
            button.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.brandTertiary.cgColor
        }
    }

    @IBAction func numberButtonTapped(_ sender: UIButton) {
        guard let titleLabel = sender.titleLabel, let value = titleLabel.text else { return }
        delegate?.onAddInputTapped(value: value)
    }

    @IBAction func backspaceButtonTapped(_ sender: Any) {
        delegate?.onBackspaceTapped()
    }
}
