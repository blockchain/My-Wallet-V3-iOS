//
//  ActionableFooterView.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class ActionableFooterView: UICollectionReusableView {
    
    static let identifier: String = String(describing: ActionableFooterView.self)
    
    // MARK: Private Static Properties
    
    fileprivate static let verticalPadding: CGFloat = 40.0
    fileprivate static let actionHeight: CGFloat = 56.0
    
    // MARK: Public
    
    var actionBlock: (() -> Void)?
    var title: String? {
        didSet {
            action.setTitle(title, for: .normal)
        }
    }
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var action: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        action.layer.cornerRadius = 4.0
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        actionBlock?()
    }
    
    // MARK: Public Static Functions
    
    static func height() -> CGFloat {
        return verticalPadding + actionHeight
    }
}
