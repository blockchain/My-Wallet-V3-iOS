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

    func toDictionary() throws -> [String: Any] {
        let data = try self.encode()
        guard let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any] else {
            throw NSError(domain: "Encodable", code: 0, userInfo: nil)
        }
        return dictionary
    }

    func tryToEncode(
        encoding: String.Encoding,
        onSuccess: (String) -> Void,
        onError: () -> Void
    ) {
        do {
            let encodedData = try self.encode()
            guard let string = String(data: encodedData, encoding: encoding) else {
                onError()
                return
            }
            onSuccess(string)
        } catch {
            onError()
        }
    }
}

extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
