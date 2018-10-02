//
//  ExchangeLockedHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeLockedHeaderView: UICollectionReusableView {
    
    // MARK: Public
    
    static let identifier: String = String(describing: ExchangeLockedHeaderView.self)
    var closeTapped: (() -> Void)?
    
    // MARK Private Static Properties
    
    static fileprivate let verticalPadding: CGFloat = 82.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var title: UILabel!
    @IBOutlet fileprivate var orderID: UILabel!
    
    var orderIdentifier: String? {
        didSet {
            guard let identifier = orderIdentifier else { return }
            orderID.text = LocalizationConstants.Exchange.orderID + "\n" + identifier
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = LocalizationConstants.Exchange.exchangeLocked
    }
    
    // MARK: Actions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        closeTapped?()
    }
    
    static func estimatedHeight() -> CGFloat {
        
        guard let titleFont = UIFont(name: Constants.FontNames.montserratRegular, size: 20) else { return 0.0 }
        guard let orderFont = UIFont(name: Constants.FontNames.montserratRegular, size: 16) else { return 0.0 }
        
        let attributedTitle = NSAttributedString(
            string: LocalizationConstants.Exchange.exchangeLocked,
            attributes: [
                NSAttributedStringKey.font: titleFont
            ]
        )
        let attributedOrder = NSAttributedString(
            string: LocalizationConstants.Exchange.orderID,
            attributes: [
                NSAttributedStringKey.font: orderFont
            ]
        )
        return verticalPadding + attributedTitle.height + attributedOrder.height*2
    }
}
