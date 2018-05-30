//
//  AssetAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Blueprint for creating asset addresses.
@objc
public protocol AssetAddress {

    var address: String { get }

    var assetType: AssetType { get }

    var description: String { get }

    init(string: String)
}
