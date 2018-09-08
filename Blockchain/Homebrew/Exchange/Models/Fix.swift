//
//  Fix.swift
//  Blockchain
//
//  Created by kevinwu on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// String that determines whether to read value as fiat or crypto
// and whether the base or counter is designated
enum Fix: String, Codable {
    case base
    case baseInFiat
    case counter
    case counterInFiat
}
