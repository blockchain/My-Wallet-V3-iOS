//
//  NewOrderTableViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class NewOrderTableViewCell: UITableViewCell {
    
    fileprivate static let verticalPadding: CGFloat = 16.0
    fileprivate static let buttonHeight: CGFloat = 56.0
    
    // MARK: Public
    
    var actionHandler: (() -> Void)?
    
    // MARK: IBOutlets
    
    @IBOutlet fileprivate var newExchangeButton: UIButton!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newExchangeButton.layer.cornerRadius = 4.0
    }
    
    // MARK: Actions
    
    @IBAction func newExchangeTapped(_ sender: UIButton) {
        actionHandler?()
    }
    
    // MARK: Static Functions
    
    static func height() -> CGFloat {
        return buttonHeight + verticalPadding + verticalPadding
    }
}
