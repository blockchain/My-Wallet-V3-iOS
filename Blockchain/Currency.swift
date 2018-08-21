//
//  Currency.swift
//  Blockchain
//
//  Created by Justin on 7/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct FiatCurrency: CustomStringConvertible {
    let name: String
    let symbol: String
    let sell: NSNumber
    let buy: NSNumber
    let last: NSNumber
    let fifteenMin: NSNumber
    var description: String { return "\(name) (\(symbol))" }
    
    init(dictionary: JSON) {
        self.name = dictionary["name"] as? String ?? ""
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.sell = dictionary["sell"] as? NSNumber ?? 0.0
        self.buy = dictionary["buy"] as? NSNumber  ?? 0.0
        self.last = dictionary["last"] as? NSNumber  ?? 0.0
        self.fifteenMin = dictionary["15m"] as? NSNumber  ?? 0.0
    }
    
    init?(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return nil }
        self.init(dictionary: json)
    }
    
    init?(string: String) {
        self.init(data: Data(string.utf8))
    }
}

struct CurrencyPair: Decodable {
    var pairs: [String]
}
