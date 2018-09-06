//
//  LayoutAttributes.swift
//  Blockchain
//
//  Created by AlexM on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct LayoutAttributes: Equatable {
    
    let minimumInterItemSpacing: CGFloat
    let minimumLineSpacing: CGFloat
    let sectionInsets: UIEdgeInsets
    
    static let exchangeDetail: LayoutAttributes = LayoutAttributes(
        minimumInterItemSpacing: 0.0,
        minimumLineSpacing: 8.0,
        sectionInsets: UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
    )
    
    static func ==(lhs: LayoutAttributes, rhs: LayoutAttributes) -> Bool {
        guard lhs.minimumInterItemSpacing == rhs.minimumInterItemSpacing else { return false }
        guard lhs.minimumLineSpacing == rhs.minimumLineSpacing else { return false }
        guard lhs.sectionInsets == rhs.sectionInsets else { return false }
        
        return true
    }
    
}
