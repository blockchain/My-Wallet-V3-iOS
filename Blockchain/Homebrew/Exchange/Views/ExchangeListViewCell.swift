//
//  ExchangeListViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeListViewCell: UITableViewCell {

    fileprivate static let separatorHeight: CGFloat = 3.0
    fileprivate static let timestampVerticalPadding: CGFloat = 16.0
    fileprivate static let timestampToStatusPadding: CGFloat = 4.0
    fileprivate static let statusToBottomPadding: CGFloat = 16.0


    // MARK: Private IBOutlets

    @IBOutlet fileprivate var timestamp: UILabel!
    @IBOutlet fileprivate var status: UILabel!
    @IBOutlet fileprivate var amountButton: UIButton!

    // MARK: Public

    func configure(with cellModel: ExchangeTradeCellModel) {
        timestamp.text = cellModel.formattedDate

        status.text = cellModel.status.displayValue
        status.textColor = cellModel.status.tintColor

        amountButton.backgroundColor = cellModel.status.tintColor
        amountButton.setTitle(cellModel.displayValue, for: .normal)
    }

    class func estimatedHeight(for model: ExchangeTradeCellModel) -> CGFloat {
        // TODO: Calculate height given string values/model
        return 75.0
    }
}
