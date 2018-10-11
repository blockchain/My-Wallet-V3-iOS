//
//  ExchangeListHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeListHeaderView: UITableViewHeaderFooterView {
    
    fileprivate static let verticalPadding: CGFloat = 16.0
    
    @IBOutlet fileprivate var title: UILabel!
    @IBOutlet fileprivate var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = LocalizationConstants.Exchange.orderHistory
        background.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.968627451, blue: 0.9764705882, alpha: 1)
    }
    
    static func height() -> CGFloat {
        let header = LocalizationConstants.Exchange.orderHistory
        guard let headerFont = UIFont(name: Constants.FontNames.montserratRegular, size: 12) else { return 0.0 }
        
        let headerHeight = NSAttributedString(string: header, attributes: [NSAttributedString.Key.font: headerFont]).height
        return verticalPadding + headerHeight
    }
    
}
