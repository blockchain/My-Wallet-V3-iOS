// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct VGSTokenizeResponse: Decodable {
    let beneficiaryId: String

    enum CodingKeys: String, CodingKey {
        case beneficiaryId = "beneficiary_id"
    }

    static func fromResponse(json: String) -> VGSTokenizeResponse? {
        try? JSONDecoder().decode(
            VGSTokenizeResponse.self,
            from: Data(json.utf8)
        )
    }
}
