//
//  LoadingTableViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class LoadingTableViewCell: UITableViewCell {
    
    // MARK: Static Properties
    
    fileprivate static let standardHeight: CGFloat = 75.0
    
    // MARK: Static Functions
    
    static func height() -> CGFloat {
        return standardHeight
    }
}
