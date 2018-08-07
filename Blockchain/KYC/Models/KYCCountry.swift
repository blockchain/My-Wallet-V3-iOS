//
//  KYCCountry.swift
//  Blockchain
//
//  Created by Maurice A. on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCCountry: Codable {
    let code: String
    let name: String
    let regions: [String]
}
