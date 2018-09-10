//
//  ExchangeDetailHeaderView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ExchangeDetailHeaderView: UICollectionReusableView {
    
    // MARK: Private Static Properties
    
    fileprivate static let verticalPadding: CGFloat = 16.0
    
    // MARK: Public Properties
    
    static let identifier = String(describing: ExchangeDetailHeaderView.self)
    
    var title: String? = nil {
        didSet {
            headerTitle.text = title
        }
    }
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var headerTitle: UILabel!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .brandPrimary
    }
    
    // MARK: Static Functions
    
    static func height(for title: String) -> CGFloat {
        guard let titleFont = UIFont(name: Constants.FontNames.montserratRegular, size: 32.0) else { return 0.0 }
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [NSAttributedStringKey.font: titleFont]
        )
        return attributedTitle.height + verticalPadding + verticalPadding
    }
}
