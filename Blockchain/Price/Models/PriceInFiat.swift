//
//  PriceInFiat.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for a quoted price by the Service-Price endpoint in fiat for a single asset type.
struct PriceInFiat: Codable {
    let timestamp: Date?
    let price: Decimal
    let volume24h: Decimal?
}

extension PriceInFiat {
    static let empty: PriceInFiat = PriceInFiat(timestamp: nil, price: 0, volume24h: nil)
}
