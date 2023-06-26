// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureReferralDomain
import FeatureSettingsDomain
import Foundation
import ToolKit

final class ReferralsAdapter: ReferralAdapterAPI {
    private let referralService: ReferralServiceAPI

    init(referralService: ReferralServiceAPI) {
        self.referralService = referralService
    }

    func hasReferral() -> AnyPublisher<Referral?, Never> {
        referralService.fetchReferralCampaign()
    }
}
