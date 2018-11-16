//
//  AssetAccount.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Describes a Blockchain account for a specific `AssetType`
public protocol AssetAccount {
    var index: Int32 { get }
    var address: String { get }
    var balance: Decimal { get }
    var name: String { get }
    var description: String { get }
}
