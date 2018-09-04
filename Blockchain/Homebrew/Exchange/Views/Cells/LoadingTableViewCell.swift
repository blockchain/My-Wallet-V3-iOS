//
//  LoadingTableViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class LoadingTableViewCell: UITableViewCell {
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Static Properties
    
    fileprivate static let standardHeight: CGFloat = 75.0
    
    // MARK: Static Functions
    
    static func height() -> CGFloat {
        return standardHeight
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// This should never not be animating.
        /// If there's ever a time when it shouldn't be
        /// animating, it shouldn't be shown.
        activityIndicator.startAnimating()
    }
}
