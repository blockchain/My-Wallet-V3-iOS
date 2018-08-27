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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = LocalizationConstants.Exchange.orderHistory
        backgroundView = UIView(frame: bounds)
        backgroundView?.backgroundColor = .gray2
    }
    
    static func height() -> CGFloat {
        let header = LocalizationConstants.Exchange.orderHistory
        guard let headerFont = UIFont(name: Constants.FontNames.montserratRegular, size: 12) else { return 0.0 }
        
        let headerHeight = NSAttributedString(string: header, attributes: [NSAttributedStringKey.font: headerFont]).height
        return verticalPadding + headerHeight
    }
    
}
