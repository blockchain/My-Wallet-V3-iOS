//
//  Limit.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct Limit: Decodable {
    let limit: Decimal
    let available: Decimal
    let used: Decimal
    
    enum CodingKeys: String, CodingKey {
        case limit
        case available
        case used
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        limit = try values.decode(String.self, forKey: .limit).toDecimal()
        available = try values.decode(String.self, forKey: .available).toDecimal()
        used = try values.decode(String.self, forKey: .used).toDecimal()
    }
}
