// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain
import Foundation

public struct PhoneVerificationResponse: Decodable {
    public let isVerified: Bool
    public let phone: String?
}
