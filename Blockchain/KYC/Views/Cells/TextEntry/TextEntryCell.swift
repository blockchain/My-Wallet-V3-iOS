//
//  TextEntryCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

protocol TextEntryCellDelegate: class {
    func textEntryCell(_ cell: TextEntryCell, enteredValue value: String)
}

class TextEntryCell: BaseTableViewCell {

    // MARK: Private Class Properties

    fileprivate static let verticalPadding: CGFloat = 16.0

    // MARK: Public Properties

    weak var delegate: TextEntryCellDelegate?

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var textField: UITextField!

    override func configure(with model: CellModel) {
        guard case let .textEntry(cellModel) = model else { return }

        textField.delegate = self
        textField.placeholder = cellModel.placeholder
        textField.text = cellModel.submission

        if cellModel.shouldBecomeFirstResponder {
            textField.becomeFirstResponder()
        }
    }

    override class func heightForProposedWidth(_ width: CGFloat, model: CellModel) -> CGFloat {
        guard case .textEntry = model else { return 0.0 }
        // TODO: Clarify sizing
        return verticalPadding + verticalPadding + verticalPadding
    }

    class func textEntryFont() -> UIFont {
        return UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraExtraExtraSmall) ?? UIFont.systemFont(ofSize: 17)
    }
}

extension TextEntryCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let value = textField.text as NSString? {
            let current = value.replacingCharacters(in: range, with: string)
            delegate?.textEntryCell(self, enteredValue: current)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
