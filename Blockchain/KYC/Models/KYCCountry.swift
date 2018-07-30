//
//  KYCCountry.swift
//  Blockchain
//
//  Created by Maurice A. on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum JSONDecodeError: Error, Equatable {
    case failedToDecodeContainer
    case failedToDecodeValueForKey
}

struct KYCCountry: Codable {
    let code: String
    let name: String
    let regions: [String]
}
