//
//  EthereumURLPayload.swift
//  Blockchain
//
//  Created by Jack on 06/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class EthereumURLPayload: EIP67URI, RawRepresentable {
    
    private enum QueryItemKeys: String {
        case value
        case gas
    }
    
    static var scheme: String {
        return Constants.Schemes.ethereum
    }
    
    var schemeCompat: String {
        return EthereumURLPayload.scheme
    }
    
    var absoluteString: String {
        return components.url!.absoluteString
    }
    
    var rawValue: String {
        return absoluteString
    }
    
    let address: String
    
    private(set) var amount: String?
    
    private(set) var gas: String?
    
    private let components: URLComponents
    
    required init?(address: String, amount: String? = nil, gas: String? = nil) {
        let components = EthereumURLPayload.urlComponents(from: address, amount: amount, gas: gas)
        guard EthereumURLPayload.valid(components: components) else {
            return nil
        }
        self.components = components
        self.address = address
        self.amount = amount
        self.gas = gas
    }
    
    required convenience init?(url: URL) {
        self.init(rawValue: url.absoluteString)
    }
    
    required init?(rawValue: String) {
        guard let components: URLComponents = URLComponents(string: rawValue) else {
            return nil
        }
        
        guard EthereumURLPayload.valid(components: components) else {
            return nil
        }
        
        self.components = components
        self.address = components.path
        
        if let queryItems = components.queryItems {
            for item in queryItems {
                if let key = QueryItemKeys(rawValue: item.name) {
                    switch key {
                    case .value:
                        self.amount = item.value
                    case .gas:
                        self.gas = item.value
                    }
                }
            }
        }
    }
    
    private static func valid(components: URLComponents) -> Bool {
        return components.scheme == EthereumURLPayload.scheme && components.path.count == 42
    }
    
    private static func urlComponents(from address: String, amount: String?, gas: String?) -> URLComponents {
        var components = URLComponents()
        components.scheme = EthereumURLPayload.scheme
        components.path = address
        
        var queryItems: [URLQueryItem] = []
        if let amount = amount {
            queryItems.append(URLQueryItem(name: QueryItemKeys.value.rawValue, value: amount))
        }
        if let gas = gas {
            queryItems.append(URLQueryItem(name: QueryItemKeys.gas.rawValue, value: gas))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return components
    }
}
