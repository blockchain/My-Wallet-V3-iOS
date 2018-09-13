//
//  TextCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class TextCell: ExchangeDetailCell {
    
    // MARK: Private Static Properties
    
    static fileprivate let verticalPadding: CGFloat = 16.0
    static fileprivate let horizontalPadding: CGFloat = 32.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    
    // MARK: Overrides
    
    override func configure(with model: ExchangeCellModel) {
        guard case let .text(payload) = model else { return }
        descriptionLabel.attributedText = payload.attributedString
    }
    
    override class func heightForProposedWidth(_ width: CGFloat, model: ExchangeCellModel) -> CGFloat {
        guard case let .text(payload) = model else { return 0.0 }
        
        let height = payload.attributedString.heightForWidth(width: width - horizontalPadding)
        return height + verticalPadding
    }
    
}
