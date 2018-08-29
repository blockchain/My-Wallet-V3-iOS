//
//  TradeLimits.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct TradeLimits: Decodable {
    let currency: String
    let minOrder: Double
    let maxOrder: Double
    let maxPossibleOrder: Double
    let daily: Limit
    let weekly: Limit
    let annual: Limit
    
    enum CodingKeys: String, CodingKey {
        case currency
        case minOrder
        case maxOrder
        case maxPossibleOrder
        case daily
        case weekly
        case annual
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decode(String.self, forKey: .currency)
        minOrder = try values.decode(String.self, forKey: .minOrder).toDouble()
        maxOrder = try values.decode(String.self, forKey: .maxOrder).toDouble()
        maxPossibleOrder = try values.decode(String.self, forKey: .maxPossibleOrder).toDouble()
        daily = try values.decode(Limit.self, forKey: .daily)
        weekly = try values.decode(Limit.self, forKey: .weekly)
        annual = try values.decode(Limit.self, forKey: .annual)
    }
    
    struct Limit: Decodable {
        let limit: Double
        let available: Double
        let used: Double
        
        enum CodingKeys: String, CodingKey {
            case limit
            case available
            case used
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            limit = try values.decode(String.self, forKey: .limit).toDouble()
            available = try values.decode(String.self, forKey: .available).toDouble()
            used = try values.decode(String.self, forKey: .used).toDouble()
        }
    }
}

extension String {
    
    enum ConversionError: Error {
        case generic
    }
    
    func toDouble() throws -> Double {
        guard let result = Double(self) else {
            throw ConversionError.generic
        }
        return result
    }
}
