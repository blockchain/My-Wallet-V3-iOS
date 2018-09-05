//
//  Rates.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct Rates: Decodable {
    let pairs: [TradingPair]
    
    enum CodingKeys: String, CodingKey {
        case pairs
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let arrayOfPairs = try values.decode([String].self, forKey: .pairs)
        let result = arrayOfPairs.map({ return TradingPair.init(string: $0) }).compactMap({ return $0 })
        pairs = result
    }
}
