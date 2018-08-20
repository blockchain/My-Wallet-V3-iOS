//
//  ExchangeListOrderCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeListOrderCell: UITableViewCell {

    // MARK: Static Properties

    fileprivate static let buttonHeight: CGFloat = 56.0
    fileprivate static let verticalPadding: CGFloat = 16.0

    // MARK: Public

    var actionHandler: (() -> Void)?

    // MARK: Actions

    @IBAction func newOrderTapped(_ sender: UIButton) {
        if let block = actionHandler {
            block()
        }
    }

    static func estimatedHeight() -> CGFloat {
        return buttonHeight + verticalPadding + verticalPadding
    }
}
