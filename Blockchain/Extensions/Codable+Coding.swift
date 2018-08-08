//
//  Codable+Code.swift
//  Blockchain
//
//  Created by kevinwu on 8/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
import Foundation

extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}

extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
