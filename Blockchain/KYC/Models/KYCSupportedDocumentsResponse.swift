//
//  KYCSupportedDocumentsResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Network response for the `/kyc/supported-documents/{country_code}`
struct KYCSupportedDocumentsResponse: Codable {
    let countryCode: String
    let documentTypes: [KYCDocumentType]

    enum CodingKeys: String, CodingKey {
        case countryCode
        case documentTypes
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.countryCode = try values.decode(String.self, forKey: .countryCode)
        let documentTypesRaw = try values.decode([String].self, forKey: .documentTypes)
        self.documentTypes = documentTypesRaw.compactMap {
            return KYCDocumentType(rawValue: $0)
        }
    }
}
