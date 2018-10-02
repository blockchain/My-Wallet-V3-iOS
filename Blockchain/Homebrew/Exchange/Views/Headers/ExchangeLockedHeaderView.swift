//
//  ExchangeLockedHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeLockedHeaderView: UICollectionReusableView {
    
    // MARK: - Public
    
    static let identifier: String = String(describing: ExchangeLockedHeaderView.self)
    var closeTapped: (() -> Void)?
    
    // MARK: - Private Static Properties
    
    static fileprivate let verticalPadding: CGFloat = 52.0
    
    // MARK: - Private IBOutlets
    
    @IBOutlet fileprivate var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = LocalizationConstants.Exchange.exchangeLocked
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        closeTapped?()
    }
    
    static func estimatedHeight() -> CGFloat {
        
        guard let titleFont = UIFont(name: Constants.FontNames.montserratRegular, size: 20) else { return 0.0 }
        
        let attributedTitle = NSAttributedString(
            string: LocalizationConstants.Exchange.exchangeLocked,
            attributes: [
                NSAttributedStringKey.font: titleFont
            ]
        )
        return verticalPadding + attributedTitle.height
    }
}
