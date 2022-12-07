// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain
import Foundation

public struct PhoneVerificationRequest: Encodable {

    private enum CodingKeys: String, CodingKey {
        case phoneNumber = "dob"
    }

    let phoneNumber: String
}
