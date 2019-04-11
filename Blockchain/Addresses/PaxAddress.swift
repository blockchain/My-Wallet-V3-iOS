//
//  PaxAddress.swift
//  Blockchain
//
//  Created by Jack on 11/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
public class PaxAddress: NSObject & AssetAddress {
    
    // MARK: - Properties
    
    public private(set) var address: String
    
    public let assetType: AssetType = .pax
    
    override public var description: String {
        return address
    }
    
    // MARK: - Initialization
    
    public required init(string: String) {
        self.address = string
    }
}
