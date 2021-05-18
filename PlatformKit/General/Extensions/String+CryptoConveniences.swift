//
//  String+CryptoConveniences.swift
//  PlatformKit
//
//  Created by Jack on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import CryptoKit

extension String {

    public var sha256: String {
        guard let data = data(using: .utf8) else {
            fatalError("Could not instantiate Data from String: \(self)")
        }
        return digestCryptoHex(input: data)
    }
    
    private func digestCryptoHex(input: Data) -> String {
        let hash = CryptoKit.SHA256.hash(data: input)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
