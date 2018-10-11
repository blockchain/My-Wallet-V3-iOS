//
//  ExchangeListViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeListViewCell: UITableViewCell {

    fileprivate static let separatorHeight: CGFloat = 1.0
    fileprivate static let totalVerticalPadding: CGFloat = 44.0


    // MARK: Private IBOutlets

    @IBOutlet fileprivate var depositAmount: UILabel!
    @IBOutlet fileprivate var receivedAmount: UILabel!
    @IBOutlet fileprivate var timestamp: UILabel!
    @IBOutlet fileprivate var status: UILabel!
    @IBOutlet fileprivate var statusImageView: UIImageView!
    
    // MARK: Public

    func configure(with cellModel: ExchangeTradeModel) {
        timestamp.text = cellModel.formattedDate
        depositAmount.text = "-" + cellModel.amountDepositedCrypto
        receivedAmount.text = cellModel.amountReceivedCrypto
        
        status.text = cellModel.status.displayValue

        statusImageView.tintColor = cellModel.status.tintColor
    }

    class func estimatedHeight(for model: ExchangeTradeModel) -> CGFloat {
        let received = model.amountReceivedCrypto
        let status = model.status.displayValue
        
        guard let receivedFont = UIFont(name: Constants.FontNames.montserratRegular, size: 16) else { return 0.0 }
        guard let statusFont = UIFont(name: Constants.FontNames.montserratRegular, size: 12) else { return 0.0 }
        
        let timestampHeight = NSAttributedString(string: received, attributes: [NSAttributedString.Key.font: receivedFont]).height
        let receivedHeight = NSAttributedString(string: status, attributes: [NSAttributedString.Key.font: statusFont]).height
        
        let labelHeights = timestampHeight + receivedHeight
        
        return separatorHeight +
            totalVerticalPadding +
            labelHeights
    }
}
