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
        let timestamp = model.formattedDate
        let status = model.status.displayValue
        
        guard let timeFont = UIFont(name: Constants.FontNames.montserratRegular, size: 12) else { return 0.0 }
        guard let statusFont = UIFont(name: Constants.FontNames.montserratRegular, size: 16) else { return 0.0 }
        
        let timestampHeight = NSAttributedString(string: timestamp, attributes: [NSAttributedStringKey.font: timeFont]).height
        let statusHeight = NSAttributedString(string: status, attributes: [NSAttributedStringKey.font: statusFont]).height
        
        let labelHeights = timestampHeight + statusHeight
        
        return separatorHeight +
            timestampVerticalPadding +
            timestampToStatusPadding +
            statusToBottomPadding +
            labelHeights
    }
}
